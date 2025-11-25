
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remote;
  ProductRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<Product>>> fetchProducts({required int limit, required int skip}) async {
    try {
      final models = await remote.fetchProducts(limit: limit, skip: skip);
      return Right(models);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message!));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
