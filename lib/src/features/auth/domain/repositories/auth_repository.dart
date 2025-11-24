import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/token.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, Token>> login(String usernameOrEmail, String password);
  Future<Either<Failure, Token>> refreshToken(String refreshToken);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
}
