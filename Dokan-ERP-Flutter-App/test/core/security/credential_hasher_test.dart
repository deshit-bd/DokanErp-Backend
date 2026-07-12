import 'package:dokan_erp/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('credential hashes are salted and verifiable', () {
    final first = CredentialHasher.hash('1234');
    final second = CredentialHasher.hash('1234');

    expect(first, isNot(second));
    expect(CredentialHasher.verify('1234', first), isTrue);
    expect(CredentialHasher.verify('9999', first), isFalse);
  });

  test('legacy plaintext credentials remain verifiable for migration', () {
    expect(CredentialHasher.verify('1234', '1234'), isTrue);
    expect(CredentialHasher.needsMigration('1234'), isTrue);
  });
}
