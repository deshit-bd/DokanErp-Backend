import 'api_authenticator.dart';
import 'api_session.dart';
import 'network_exception.dart';

typedef ApiSessionRefresher = Future<ApiSession?> Function(String refreshToken);

class RefreshingApiAuthenticator implements ApiAuthenticator {
  RefreshingApiAuthenticator({
    required ApiSessionStore sessionStore,
    required ApiSessionRefresher refresh,
  })  : _sessionStore = sessionStore,
        _refresh = refresh;

  final ApiSessionStore _sessionStore;
  final ApiSessionRefresher _refresh;
  Future<bool>? _activeRefresh;

  @override
  Future<String?> getAccessToken() async {
    final session = await _sessionStore.read();
    if (session == null || session.accessToken.isEmpty) return null;
    if (session.isExpired && session.refreshToken.isNotEmpty) {
      final refreshed = await refreshSession();
      if (!refreshed) return null;
      return (await _sessionStore.read())?.accessToken;
    }
    return session.accessToken;
  }

  @override
  Future<bool> refreshSession() {
    return _activeRefresh ??= _refreshOnce().whenComplete(() {
      _activeRefresh = null;
    });
  }

  Future<bool> _refreshOnce() async {
    final current = await _sessionStore.read();
    if (current == null || current.refreshToken.isEmpty) {
      await _sessionStore.clear();
      return false;
    }
    try {
      final refreshed = await _refresh(current.refreshToken);
      if (refreshed == null || refreshed.accessToken.isEmpty) {
        await _sessionStore.clear();
        return false;
      }
      await _sessionStore.write(
        refreshed.refreshToken.isEmpty
            ? refreshed.copyWith(refreshToken: current.refreshToken)
            : refreshed,
      );
      return true;
    } catch (e) {
      if (e is NetworkException && (e.statusCode == 401 || e.statusCode == 403)) {
        await _sessionStore.clear();
        return false;
      }
      rethrow;
    }
  }

  @override
  Future<void> clearSession() => _sessionStore.clear();
}
