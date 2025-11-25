import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/product_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/product.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  StreamSubscription<dynamic>? _connectivitySub;
  bool _isOffline = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(FetchProducts());

    _scrollController.addListener(_onScroll);
    _connectivitySub = Connectivity().onConnectivityChanged.listen((event) {
      ConnectivityResult? result;
      if (event is ConnectivityResult) {
        result = event as ConnectivityResult?;
      } else if (event.isNotEmpty) {
        result = event.first;
      } else if (event.isNotEmpty) {
        final first = event.first;
        result = first;
      }


      final offline = result == ConnectivityResult.none;
      if (!mounted) return;
      setState(() {
        _isOffline = offline;
      });
    });

  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    if (offset >= max * 0.9) {
      final state = context.read<ProductBloc>().state;
      if (state is ProductLoadInProgress) return;
      if (state is ProductLoadSuccess && state.hasReachedMax) return;
      context.read<ProductBloc>().add(FetchProducts());
    }
  }


  Future<void> _onRefresh() async {
    context.read<ProductBloc>().add(RefreshProducts());
    await Future.delayed(const Duration(milliseconds: 600));
  }

  List<Product> _filter(List<Product> list) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((p) {
      return p.title.toLowerCase().contains(q) || p.description.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: _buildSearchField(),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_isOffline) _buildOfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ProductLoadInProgress) {
                    final existing = state.existing;
                    if (existing.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return _buildList(existing, isLoading: true);
                    }
                  }

                  if (state is ProductLoadFailure) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Failed to load products', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(state.message, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => context.read<ProductBloc>().add(FetchProducts(forceRefresh: true)),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is ProductLoadSuccess) {
                    final all = state.products;
                    if (all.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(child: Text('No products found', style: Theme.of(context).textTheme.titleMedium)),
                          ),
                        ],
                      );
                    }
                    final filtered = _filter(all);
                    final hasMore = !state.hasReachedMax;
                    return _buildList(filtered, hasMore: hasMore);
                  }

                  // Fallback: render empty list
                  return const Center(child: Text('No products'));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Product> items, {bool hasMore = false, bool isLoading = false}) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length + (hasMore || isLoading ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final p = items[index];
        return _buildProductTile(p);
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search products...',
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
            setState(() => _searchQuery = '');
          },
        )
            : null,
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      onChanged: (v) => setState(() => _searchQuery = v),
      onSubmitted: (v) => setState(() => _searchQuery = v),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      color: Colors.amber.shade700,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: const [
          Icon(Icons.cloud_off, color: Colors.white),
          SizedBox(width: 8),
          Expanded(child: Text('You are offline — showing cached data', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildProductTile(Product p) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      leading: SizedBox(
        width: 72,
        height: 72,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: p.thumbnail,
            fit: BoxFit.cover,
            placeholder: (c, s) => Container(color: Colors.grey.shade200),
            errorWidget: (c, s, e) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
          ),
        ),
      ),
      title: Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text('\$${p.price}', style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () {
      },
    );
  }
}
