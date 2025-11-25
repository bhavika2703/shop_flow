import '../../domain/entities/token.dart';

class TokenModel extends Token {
  TokenModel({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) : super(
         accessToken: accessToken,
         refreshToken: refreshToken,
         expiresAt: expiresAt,
       );

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    final access = (json['token'] ?? json['accessToken']) as String? ?? '';
    final refresh =
        (json['refreshToken'] ?? json['refresh_token']) as String? ?? '';
    final expiresAt = DateTime.now().add(const Duration(hours: 1));
    return TokenModel(
      accessToken: access,
      refreshToken: refresh,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt.toIso8601String(),
  };

  factory TokenModel.fromStorage(Map<String, String> map) {
    final access = map['access_token'] ?? '';
    final refresh = map['refresh_token'] ?? '';
    final expiresStr = map['expires_at'];
    final expires = expiresStr != null
        ? DateTime.parse(expiresStr)
        : DateTime.now();
    return TokenModel(
      accessToken: access,
      refreshToken: refresh,
      expiresAt: expires,
    );
  }
}
