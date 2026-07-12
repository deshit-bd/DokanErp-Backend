import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('concurrent refresh calls share one refresh request', () async {
    final store = _MemorySessionStore(
      ApiSession(
        accessToken: 'expired',
        refreshToken: 'refresh',
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    );
    var refreshCalls = 0;
    final authenticator = RefreshingApiAuthenticator(
      sessionStore: store,
      refresh: (token) async {
        refreshCalls++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return const ApiSession(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        );
      },
    );

    final results = await Future.wait([
      authenticator.refreshSession(),
      authenticator.refreshSession(),
      authenticator.refreshSession(),
    ]);

    expect(results, everyElement(isTrue));
    expect(refreshCalls, 1);
    expect((await store.read())?.accessToken, 'new-access');
  });

  test('failed refresh clears the session', () async {
    final store = _MemorySessionStore(
      const ApiSession(accessToken: 'old', refreshToken: 'refresh'),
    );
    final authenticator = RefreshingApiAuthenticator(
      sessionStore: store,
      refresh: (_) async => null,
    );

    expect(await authenticator.refreshSession(), isFalse);
    expect(await store.read(), isNull);
  });

  test('keeps the current refresh token when backend returns only access token',
      () async {
    final store = _MemorySessionStore(
      const ApiSession(accessToken: 'old', refreshToken: 'keep-me'),
    );
    final authenticator = RefreshingApiAuthenticator(
      sessionStore: store,
      refresh: (_) async => const ApiSession(
        accessToken: 'new-access',
        refreshToken: '',
      ),
    );

    expect(await authenticator.refreshSession(), isTrue);
    expect((await store.read())?.accessToken, 'new-access');
    expect((await store.read())?.refreshToken, 'keep-me');
  });
}

class _MemorySessionStore implements ApiSessionStore {
  _MemorySessionStore(this.session);

  ApiSession? session;

  @override
  Future<void> clear() async => session = null;

  @override
  Future<ApiSession?> read() async => session;

  @override
  Future<void> write(ApiSession value) async => session = value;
}
