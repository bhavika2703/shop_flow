import 'package:dio/dio.dart';
import '../models/token_model.dart';

abstract class AuthRemoteDataSource {
  Future<TokenModel> login(String username, String password);
  Future<TokenModel> refresh(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<TokenModel> login(String username, String password) async {
    final res = await dio.post(
      'https://dummyjson.com/auth/login',
      data: {'username': username, 'password': password},
    );
    return TokenModel.fromJson(res.data);
  }

  @override
  Future<TokenModel> refresh(String refreshToken) async {
    final res = await dio.post(
      'https://dummyjson.com/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return TokenModel.fromJson(res.data);
  }
}
