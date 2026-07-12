abstract interface class ApiAuthenticator {
  Future<String?> getAccessToken();
  Future<bool> refreshSession();
  Future<void> clearSession();
}
