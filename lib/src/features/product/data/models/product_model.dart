import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required int id,
    required String title,
    required String description,
    required num price,
    required String thumbnail,
  }) : super(id: id, title: title, description: description, price: price, thumbnail: thumbnail);

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: json['price'] as num? ?? 0,
      thumbnail: json['thumbnail'] as String? ?? '',
    );
  }
}
