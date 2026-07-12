class ApiSession {
  const ApiSession({
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
    this.tokenType = 'Bearer',
  });

  final String accessToken;
  final String refreshToken;
  final DateTime? expiresAt;
  final String tokenType;

  bool get isExpired =>
      expiresAt != null &&
      DateTime.now().isAfter(expiresAt!.subtract(const Duration(seconds: 30)));

  ApiSession copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? tokenType,
  }) {
    return ApiSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt?.toIso8601String(),
        'tokenType': tokenType,
      };

  factory ApiSession.fromJson(Map<String, dynamic> json) {
    final expiresAtValue = json['expiresAt'] ?? json['expires_at'];
    final expiresInValue = json['expiresIn'] ?? json['expires_in'];
    final expiresInSeconds = expiresInValue is num
        ? expiresInValue.toInt()
        : int.tryParse('$expiresInValue');
    final expiresAt = expiresAtValue == null
        ? (expiresInSeconds == null
            ? null
            : DateTime.now().add(Duration(seconds: expiresInSeconds)))
        : DateTime.tryParse('$expiresAtValue');
    return ApiSession(
      accessToken:
          '${json['accessToken'] ?? json['access_token'] ?? json['token'] ?? ''}',
      refreshToken: '${json['refreshToken'] ?? json['refresh_token'] ?? ''}',
      expiresAt: expiresAt,
      tokenType: '${json['tokenType'] ?? json['token_type'] ?? 'Bearer'}',
    );
  }
}

abstract interface class ApiSessionStore {
  Future<ApiSession?> read();
  Future<void> write(ApiSession session);
  Future<void> clear();
}
