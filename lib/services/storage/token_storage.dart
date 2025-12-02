abstract class TokenStorage {
  Future<void> init();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> setTokens(String accessToken, String refreshToken);
  Future<void> clearTokens();
}
