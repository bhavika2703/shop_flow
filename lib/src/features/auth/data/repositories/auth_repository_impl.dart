import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/token.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  Token? _currentToken;

  AuthRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, Token>> login(
    String emailOrUsername,
    String password,
  ) async {
    try {
      final tokenModel = await remote.login(emailOrUsername, password);
      _currentToken = tokenModel;
      return Right(tokenModel);
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Token>> refreshToken(String refreshToken) async {
    try {
      final tokenModel = await remote.refresh(refreshToken);
      _currentToken = tokenModel;
      return Right(tokenModel);
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      _currentToken = null;
      return const Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    final token = _currentToken;
    if (token == null) return Left(AuthFailure('No token in memory'));
    final user = User(id: '1', email: 'user@example.com', name: 'Demo User');
    return Right(user);
  }
}
