part of 'product_bloc.dart';

abstract class ProductEvent {}

class FetchProducts extends ProductEvent {
  final bool forceRefresh;
  FetchProducts({this.forceRefresh = false});
}

class RefreshProducts extends ProductEvent {}
