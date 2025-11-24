import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/token_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(TokenModel token);
  Future<TokenModel?> getToken();
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;
  AuthLocalDataSourceImpl(this.storage);

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kExpires = 'expires_at';

  @override
  Future<void> saveToken(TokenModel token) async {
    await storage.write(key: _kAccess, value: token.accessToken);
    await storage.write(key: _kRefresh, value: token.refreshToken);
    await storage.write(key: _kExpires, value: token.expiresAt.toIso8601String());
  }

  @override
  Future<TokenModel?> getToken() async {
    final map = <String, String?>{
      _kAccess: await storage.read(key: _kAccess),
      _kRefresh: await storage.read(key: _kRefresh),
      _kExpires: await storage.read(key: _kExpires),
    };
    if ((map[_kAccess] ?? '').isEmpty || (map[_kRefresh] ?? '').isEmpty) return null;
    return TokenModel.fromStorage(map.map((k, v) => MapEntry(k, v ?? '')));
  }

  @override
  Future<void> clear() async {
    await storage.delete(key: _kAccess);
    await storage.delete(key: _kRefresh);
    await storage.delete(key: _kExpires);
  }
}
