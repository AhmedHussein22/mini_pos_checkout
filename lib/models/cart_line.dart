import 'package:equatable/equatable.dart';
import 'item.dart';

class CartLine extends Equatable {
  final Item item;
  final int quantity;

  const CartLine({
    required this.item,
    required this.quantity,
  });

  double get totalPrice => item.price * quantity;

  CartLine copyWith({
    Item? item,
    int? quantity,
  }) {
    return CartLine(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item.toJson(),
      'quantity': quantity,
    };
  }

  factory CartLine.fromJson(Map<String, dynamic> json) {
    return CartLine(
      item: Item.fromJson(json['item'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  @override
  List<Object> get props => [item, quantity];
}
