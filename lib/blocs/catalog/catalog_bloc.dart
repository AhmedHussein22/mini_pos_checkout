import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:mini_pos_checkout/models/item.dart';

import 'catalog_event.dart';
import 'catalog_state.dart';

/// Manages the catalog loading process.
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final AssetBundle assetBundle;

  CatalogBloc({required this.assetBundle}) : super(const CatalogInitial()) {
    on<LoadCatalog>(_onLoadCatalog);
    on<RefreshCatalog>(_onRefreshCatalog);
  }

  Future<void> _onLoadCatalog(LoadCatalog event, Emitter<CatalogState> emit) async {
    emit(const CatalogLoading());
    try {
      final items = await _loadCatalogItems();
      emit(CatalogLoaded(items));
    } catch (e) {
      emit(CatalogError('Failed to load catalog: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshCatalog(RefreshCatalog event, Emitter<CatalogState> emit) async {
    try {
      final items = await _loadCatalogItems();
      emit(CatalogLoaded(items));
    } catch (e) {
      emit(CatalogError('Failed to refresh catalog: ${e.toString()}'));
    }
  }

  Future<List<Item>> _loadCatalogItems() async {
    final String jsonString = await assetBundle.loadString('assets/catalog.json');
    final List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData
        .map((item) => Item(
              id: item['id'] as String,
              name: item['name'] as String,
              price: (item['price'] as num).toDouble(),
            ))
        .toList();
  }
}
