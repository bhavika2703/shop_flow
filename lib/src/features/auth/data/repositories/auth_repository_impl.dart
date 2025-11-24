import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/token.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, Token>> login(String emailOrUsername, String password) async {
    try {
      final tokenModel = await remote.login(emailOrUsername, password);
      await local.saveToken(tokenModel);
      return Right(tokenModel);
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Token>> refreshToken(String refreshToken) async {
    try {
      final tokenModel = await remote.refresh(refreshToken);
      await local.saveToken(tokenModel);
      return Right(tokenModel);
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await local.clear();
      return const Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    // For assignment, we return a simple stored placeholder or a failure if not logged in.
    final token = await local.getToken();
    if (token == null) return Left(AuthFailure('No token'));
    // DummyJSON doesn't have a /auth/me stable endpoint in this code path; return placeholder.
    final user = User(id: '1', email: 'user@example.com', name: 'Demo User');
    return Right(user);
  }
}
