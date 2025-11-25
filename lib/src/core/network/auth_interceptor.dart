import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  AuthInterceptor(this.storage);

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kExpires = 'expires_at';

  Future<String?> _getAccess() => storage.read(key: _kAccess);

  Future<String?> _getRefresh() => storage.read(key: _kRefresh);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _getAccess();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;
    final hasRetried = req.extra['retry'] == true;

    if (!isUnauthorized || hasRetried) {
      return handler.next(err);
    }
    final refresh = await _getRefresh();
    if (refresh == null || refresh.isEmpty) {
      await _clearTokens();
      return handler.next(err);
    }

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final resp = await dio.post(
        'https://dummyjson.com/auth/refresh',
        data: {'refreshToken': refresh},
      );

      final data = resp.data as Map<String, dynamic>;
      final newAccess = (data['token'] ?? data['accessToken'] ?? '') as String;
      final newRefresh =
          (data['refreshToken'] ?? data['refresh_token'] ?? '') as String;
      final expiresAt = DateTime.now().add(const Duration(hours: 1));

      if (newAccess.isEmpty || newRefresh.isEmpty) {
        await _clearTokens();
        return handler.next(err);
      }

      await storage.write(key: _kAccess, value: newAccess);
      await storage.write(key: _kRefresh, value: newRefresh);
      await storage.write(key: _kExpires, value: expiresAt.toIso8601String());

      final options = Options(
        method: req.method,
        headers: {...req.headers, 'Authorization': 'Bearer $newAccess'},
        responseType: req.responseType,
        contentType: req.contentType,
        extra: {...req.extra, 'retry': true},
        followRedirects: req.followRedirects,
        validateStatus: req.validateStatus,
        receiveDataWhenStatusError: req.receiveDataWhenStatusError,
        sendTimeout: req.sendTimeout,
        receiveTimeout: req.receiveTimeout,
      );

      final retryResponse = await dio.request(
        req.path,
        data: req.data,
        queryParameters: req.queryParameters,
        options: options,
      );

      return handler.resolve(retryResponse);
    } catch (e) {
      await _clearTokens();
      return handler.next(err);
    }
  }

  Future<void> _clearTokens() async {
    try {
      await storage.delete(key: _kAccess);
      await storage.delete(key: _kRefresh);
      await storage.delete(key: _kExpires);
    } catch (_) {
      // ignore
    }
  }
}
