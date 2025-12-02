#!/usr/bin/env python3
import http.server
import socketserver
import os

PORT = 5000
DIRECTORY = "build/web"

class SPAHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_GET(self):
        path = self.path.split('?')[0]
        file_path = os.path.join(DIRECTORY, path.lstrip('/'))
        
        if os.path.exists(file_path) and os.path.isfile(file_path):
            super().do_GET()
        elif '.' in os.path.basename(path):
            super().do_GET()
        else:
            self.path = '/index.html'
            super().do_GET()

    def end_headers(self):
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

class ReuseAddrTCPServer(socketserver.TCPServer):
    allow_reuse_address = True

if __name__ == "__main__":
    with ReuseAddrTCPServer(("0.0.0.0", PORT), SPAHandler) as httpd:
        print(f"Serving EVHub on http://0.0.0.0:{PORT}")
        httpd.serve_forever()
