import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:bloc/bloc.dart';
import '../../models/item.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc() : super(const CatalogInitial()) {
    on<LoadCatalog>(_onLoadCatalog);
    on<RefreshCatalog>(_onRefreshCatalog);
  }

  Future<void> _onLoadCatalog(
    LoadCatalog event,
    Emitter<CatalogState> emit,
  ) async {
    emit(const CatalogLoading());
    try {
      final items = await _loadCatalogFromAssets();
      emit(CatalogLoaded(items));
    } catch (e) {
      emit(CatalogError('Failed to load catalog: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshCatalog(
    RefreshCatalog event,
    Emitter<CatalogState> emit,
  ) async {
    try {
      final items = await _loadCatalogFromAssets();
      emit(CatalogLoaded(items));
    } catch (e) {
      emit(CatalogError('Failed to refresh catalog: ${e.toString()}'));
    }
  }

  Future<List<Item>> _loadCatalogFromAssets() async {
    final String response = await rootBundle.loadString('assets/catalog.json');
    final Map<String, dynamic> data = json.decode(response);
    final List<dynamic> itemsJson = data['items'];
    
    return itemsJson
        .map((json) => Item.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
