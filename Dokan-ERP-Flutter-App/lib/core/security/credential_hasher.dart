import 'dart:convert';
import 'dart:math';

abstract final class CredentialHasher {
  static const _rounds = 12000;
  static const _prefix = 'sha256';

  static String hash(String credential, {String? salt}) {
    final actualSalt = salt ?? _randomSalt();
    List<int> bytes = utf8.encode('$actualSalt:$credential');
    for (var i = 0; i < _rounds; i++) {
      bytes = _sha256(bytes);
    }
    return '$_prefix\$$_rounds\$$actualSalt\$${base64UrlEncode(bytes)}';
  }

  static bool verify(String credential, String encoded) {
    final parts = encoded.split(r'$');
    if (parts.length != 4 || parts.first != _prefix) {
      return credential == encoded;
    }
    final salt = parts[2];
    final candidate = hash(credential, salt: salt);
    return _constantTimeEquals(candidate, encoded);
  }

  static bool needsMigration(String encoded) =>
      !encoded.startsWith('$_prefix\$');

  static String _randomSalt() {
    final random = Random.secure();
    return base64UrlEncode(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
  }

  static bool _constantTimeEquals(String left, String right) {
    if (left.length != right.length) return false;
    var difference = 0;
    for (var i = 0; i < left.length; i++) {
      difference |= left.codeUnitAt(i) ^ right.codeUnitAt(i);
    }
    return difference == 0;
  }

  static List<int> _sha256(List<int> input) {
    const constants = <int>[
      0x428a2f98,
      0x71374491,
      0xb5c0fbcf,
      0xe9b5dba5,
      0x3956c25b,
      0x59f111f1,
      0x923f82a4,
      0xab1c5ed5,
      0xd807aa98,
      0x12835b01,
      0x243185be,
      0x550c7dc3,
      0x72be5d74,
      0x80deb1fe,
      0x9bdc06a7,
      0xc19bf174,
      0xe49b69c1,
      0xefbe4786,
      0x0fc19dc6,
      0x240ca1cc,
      0x2de92c6f,
      0x4a7484aa,
      0x5cb0a9dc,
      0x76f988da,
      0x983e5152,
      0xa831c66d,
      0xb00327c8,
      0xbf597fc7,
      0xc6e00bf3,
      0xd5a79147,
      0x06ca6351,
      0x14292967,
      0x27b70a85,
      0x2e1b2138,
      0x4d2c6dfc,
      0x53380d13,
      0x650a7354,
      0x766a0abb,
      0x81c2c92e,
      0x92722c85,
      0xa2bfe8a1,
      0xa81a664b,
      0xc24b8b70,
      0xc76c51a3,
      0xd192e819,
      0xd6990624,
      0xf40e3585,
      0x106aa070,
      0x19a4c116,
      0x1e376c08,
      0x2748774c,
      0x34b0bcb5,
      0x391c0cb3,
      0x4ed8aa4a,
      0x5b9cca4f,
      0x682e6ff3,
      0x748f82ee,
      0x78a5636f,
      0x84c87814,
      0x8cc70208,
      0x90befffa,
      0xa4506ceb,
      0xbef9a3f7,
      0xc67178f2,
    ];
    final bytes = List<int>.from(input);
    final bitLength = bytes.length * 8;
    bytes.add(0x80);
    while (bytes.length % 64 != 56) {
      bytes.add(0);
    }
    for (var i = 7; i >= 0; i--) {
      bytes.add((bitLength >> (i * 8)) & 0xff);
    }

    var h0 = 0x6a09e667;
    var h1 = 0xbb67ae85;
    var h2 = 0x3c6ef372;
    var h3 = 0xa54ff53a;
    var h4 = 0x510e527f;
    var h5 = 0x9b05688c;
    var h6 = 0x1f83d9ab;
    var h7 = 0x5be0cd19;

    for (var offset = 0; offset < bytes.length; offset += 64) {
      final words = List<int>.filled(64, 0);
      for (var i = 0; i < 16; i++) {
        final index = offset + i * 4;
        words[i] = (bytes[index] << 24) |
            (bytes[index + 1] << 16) |
            (bytes[index + 2] << 8) |
            bytes[index + 3];
      }
      for (var i = 16; i < 64; i++) {
        final s0 = _rotateRight(words[i - 15], 7) ^
            _rotateRight(words[i - 15], 18) ^
            (words[i - 15] >> 3);
        final s1 = _rotateRight(words[i - 2], 17) ^
            _rotateRight(words[i - 2], 19) ^
            (words[i - 2] >> 10);
        words[i] = (words[i - 16] + s0 + words[i - 7] + s1) & 0xffffffff;
      }

      var a = h0;
      var b = h1;
      var c = h2;
      var d = h3;
      var e = h4;
      var f = h5;
      var g = h6;
      var h = h7;
      for (var i = 0; i < 64; i++) {
        final s1 =
            _rotateRight(e, 6) ^ _rotateRight(e, 11) ^ _rotateRight(e, 25);
        final choice = (e & f) ^ ((~e) & g);
        final temp1 = (h + s1 + choice + constants[i] + words[i]) & 0xffffffff;
        final s0 =
            _rotateRight(a, 2) ^ _rotateRight(a, 13) ^ _rotateRight(a, 22);
        final majority = (a & b) ^ (a & c) ^ (b & c);
        final temp2 = (s0 + majority) & 0xffffffff;
        h = g;
        g = f;
        f = e;
        e = (d + temp1) & 0xffffffff;
        d = c;
        c = b;
        b = a;
        a = (temp1 + temp2) & 0xffffffff;
      }
      h0 = (h0 + a) & 0xffffffff;
      h1 = (h1 + b) & 0xffffffff;
      h2 = (h2 + c) & 0xffffffff;
      h3 = (h3 + d) & 0xffffffff;
      h4 = (h4 + e) & 0xffffffff;
      h5 = (h5 + f) & 0xffffffff;
      h6 = (h6 + g) & 0xffffffff;
      h7 = (h7 + h) & 0xffffffff;
    }

    final result = <int>[];
    for (final value in [h0, h1, h2, h3, h4, h5, h6, h7]) {
      result
        ..add((value >> 24) & 0xff)
        ..add((value >> 16) & 0xff)
        ..add((value >> 8) & 0xff)
        ..add(value & 0xff);
    }
    return result;
  }

  static int _rotateRight(int value, int amount) {
    return ((value >> amount) | (value << (32 - amount))) & 0xffffffff;
  }
}
