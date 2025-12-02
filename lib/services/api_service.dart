import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _accessToken;
  String? _refreshToken;

  Future<void> init() async {
    try {
      _accessToken = html.window.localStorage['access_token'];
      _refreshToken = html.window.localStorage['refresh_token'];
    } catch (_) {
      _accessToken = null;
      _refreshToken = null;
    }
  }

  Future<void> setTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    try {
      html.window.localStorage['access_token'] = accessToken;
      html.window.localStorage['refresh_token'] = refreshToken;
    } catch (_) {}
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    try {
      html.window.localStorage.remove('access_token');
      html.window.localStorage.remove('refresh_token');
    } catch (_) {}
  }

  bool get isAuthenticated => _accessToken != null;
  String? get accessToken => _accessToken;

  Map<String, String> get _headers {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      var uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri, headers: _headers).timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await http
          .post(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await http
          .put(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await http.delete(uri, headers: _headers).timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    Map<String, dynamic>? data;

    try {
      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      data = null;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return data ?? {'success': true};
    }

    final message = data?['message'] ?? data?['error'] ?? 'An error occurred';

    if (statusCode == 401) {
      throw ApiException('Unauthorized. Please login again.', statusCode: statusCode, data: data);
    } else if (statusCode == 403) {
      throw ApiException('Access denied.', statusCode: statusCode, data: data);
    } else if (statusCode == 404) {
      throw ApiException('Resource not found.', statusCode: statusCode, data: data);
    } else if (statusCode == 422) {
      throw ApiException(message, statusCode: statusCode, data: data);
    } else if (statusCode >= 500) {
      throw ApiException('Server error. Please try again later.', statusCode: statusCode, data: data);
    }

    throw ApiException(message, statusCode: statusCode, data: data);
  }

  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/refresh');
      final response = await http.post(
        uri,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({'refreshToken': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await setTokens(data['accessToken'], data['refreshToken'] ?? _refreshToken!);
        return true;
      }
    } catch (_) {}

    await clearTokens();
    return false;
  }
}
