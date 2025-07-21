import 'package:equatable/equatable.dart';
import 'package:mini_pos_checkout/models/item.dart';

abstract class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object> get props => [];
}

class CatalogInitial extends CatalogState {
  const CatalogInitial();
}

class CatalogLoading extends CatalogState {
  const CatalogLoading();
}

class CatalogLoaded extends CatalogState {
  final List<Item> items;

  const CatalogLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class CatalogError extends CatalogState {
  final String message;

  const CatalogError(this.message);

  @override
  List<Object> get props => [message];
}
