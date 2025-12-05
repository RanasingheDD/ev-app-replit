import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<AuthResult> login(String email, String password) async {
    final response = await _api.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    final tokens = AuthTokens.fromJson(response);
    await _api.setTokens(tokens.accessToken, tokens.refreshToken);

    final user = await getCurrentUser();
    return AuthResult(user: user, tokens: tokens);
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _api.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );

    final tokens = AuthTokens.fromJson(response);
    await _api.setTokens(tokens.accessToken, tokens.refreshToken);

    final user = await getCurrentUser();
    return AuthResult(user: user, tokens: tokens);
  }

  Future<User> getCurrentUser() async {
    final response = await _api.get('/users/me');
    return User.fromJson(response);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    await _api.clearTokens();
  }

  Future<void> forgotPassword(String email) async {
    await _api.post('/auth/forgot-password', body: {'email': email});
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _api.post(
      '/auth/reset-password',
      body: {'token': token, 'password': newPassword},
    );
  }

  Future<User> updateProfile({String? name, String? phone}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;

    final response = await _api.put('/users/me', body: body);
    return User.fromJson(response);
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await _api.post(
      '/auth/change-password',
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  bool get isAuthenticated => _api.isAuthenticated;

  Future<bool> tryAutoLogin() async {
    await _api.init();
    if (!_api.isAuthenticated) return false;

    try {
      await getCurrentUser();
      return true;
    } catch (_) {
      final refreshed = await _api.refreshAccessToken();
      if (refreshed) {
        try {
          await getCurrentUser();
          return true;
        } catch (_) {}
      }
      await _api.clearTokens();
      return false;
    }
  }
}

class AuthResult {
  final User user;
  final AuthTokens tokens;

  AuthResult({required this.user, required this.tokens});
}
