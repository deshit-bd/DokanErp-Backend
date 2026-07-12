import 'package:dokan_erp/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses snake_case token response and expires_in', () {
    final before = DateTime.now().add(const Duration(seconds: 110));
    final session = ApiSession.fromJson({
      'access_token': 'access',
      'refresh_token': 'refresh',
      'expires_in': 120,
      'token_type': 'Bearer',
    });

    expect(session.accessToken, 'access');
    expect(session.refreshToken, 'refresh');
    expect(session.expiresAt, isNotNull);
    expect(session.expiresAt!.isAfter(before), isTrue);
  });

  test('parses camelCase token response and ISO expiry', () {
    final expiry = DateTime.utc(2030, 1, 1);
    final session = ApiSession.fromJson({
      'accessToken': 'access',
      'refreshToken': 'refresh',
      'expiresAt': expiry.toIso8601String(),
    });

    expect(session.expiresAt, expiry);
    expect(session.isExpired, isFalse);
  });
}
