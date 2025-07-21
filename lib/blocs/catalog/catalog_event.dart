import 'package:equatable/equatable.dart';

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object> get props => [];
}

class LoadCatalog extends CatalogEvent {
  const LoadCatalog();
}

class RefreshCatalog extends CatalogEvent {
  const RefreshCatalog();
}
