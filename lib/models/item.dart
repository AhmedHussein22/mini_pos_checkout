import 'package:equatable/equatable.dart';

/// Represents a product in the catalog.
class Item extends Equatable {
  const Item({
    required this.id,
    required this.name,
    required this.price,
    this.description,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }

  final String id;
  final String name;
  final double price;
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [id, name, price, description];
}
