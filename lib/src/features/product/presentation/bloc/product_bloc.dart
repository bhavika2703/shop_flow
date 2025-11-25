import 'package:bloc/bloc.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

part 'product_event.dart';

part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;
  static const int pageSize = 20;

  ProductBloc({required this.repository}) : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
    on<RefreshProducts>(_onRefreshProducts);
  }

  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    final current = state;

    if (current is ProductLoadInProgress) {
      return;
    }

    if (current is ProductLoadSuccess &&
        current.hasReachedMax &&
        !event.forceRefresh) {
      return;
    }

    List<Product> items = [];
    int skip = 0;
    if (current is ProductLoadSuccess && !event.forceRefresh) {
      items = current.products;
      skip = items.length; // next page offset
    }

    emit(ProductLoadInProgress(existing: items));

    final res = await repository.fetchProducts(limit: pageSize, skip: skip);

    res.fold(
      (failure) {
        emit(ProductLoadFailure(message: failure.message));
      },
      (newItems) {
        final all = [...items, ...newItems];

        final reachedMax = newItems.length < pageSize;

        emit(ProductLoadSuccess(products: all, hasReachedMax: reachedMax));
      },
    );
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoadInProgress(existing: []));
    final res = await repository.fetchProducts(limit: pageSize, skip: 0);
    res.fold(
      (failure) => emit(ProductLoadFailure(message: failure.message)),
      (items) => emit(
        ProductLoadSuccess(
          products: items,
          hasReachedMax: items.length < pageSize,
        ),
      ),
    );
  }
}
