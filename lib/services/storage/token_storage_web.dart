import 'dart:html' as html;
import 'token_storage.dart';

class TokenStorageImpl implements TokenStorage {
  @override
  Future<void> init() async {}

  @override
  Future<String?> getAccessToken() async {
    try {
      return html.window.localStorage['access_token'];
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return html.window.localStorage['refresh_token'];
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setTokens(String accessToken, String refreshToken) async {
    try {
      html.window.localStorage['access_token'] = accessToken;
      html.window.localStorage['refresh_token'] = refreshToken;
    } catch (_) {}
  }

  @override
  Future<void> clearTokens() async {
    try {
      html.window.localStorage.remove('access_token');
      html.window.localStorage.remove('refresh_token');
    } catch (_) {}
  }
}
