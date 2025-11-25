import 'package:dio/dio.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> fetchProducts({required int limit, required int skip});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;
  ProductRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ProductModel>> fetchProducts({required int limit, required int skip}) async {
    final res = await dio.get('https://dummyjson.com/products', queryParameters: {
      'limit': limit,
      'skip': skip,
    });
    final data = res.data as Map<String, dynamic>;
    final list = (data['products'] as List<dynamic>? ?? []);
    return list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
