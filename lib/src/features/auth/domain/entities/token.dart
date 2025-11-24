class Token {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  Token({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  @override
  String toString() {
    return 'Token(accessToken: $accessToken, refreshToken: $refreshToken, expiresAt: $expiresAt)';
  }
}
