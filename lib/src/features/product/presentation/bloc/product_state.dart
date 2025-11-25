part of 'product_bloc.dart';


abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoadInProgress extends ProductState {
  final List<Product> existing;
  ProductLoadInProgress({required this.existing});
}

class ProductLoadSuccess extends ProductState {
  final List<Product> products;
  final bool hasReachedMax;
  ProductLoadSuccess({required this.products, required this.hasReachedMax});
}

class ProductLoadFailure extends ProductState {
  final String message;
  ProductLoadFailure({required this.message});
}
