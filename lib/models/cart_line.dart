import 'package:equatable/equatable.dart';
import 'package:mini_pos_checkout/models/item.dart';

/// Represents an item in the cart with quantity and optional discount.
class CartLine extends Equatable {
  final Item item;
  final int quantity;
  final double discount;

  const CartLine({
    required this.item,
    required this.quantity,
    this.discount = 0.0,
  });

  /// Calculates the total price for this cart line (price * quantity - discount).
  double get total {
    final subtotal = item.price * quantity;
    final totalAfterDiscount = subtotal - discount;
    final result = totalAfterDiscount < 0 ? 0.0 : totalAfterDiscount;
    return double.parse(result.toStringAsFixed(2));
  }

  // Keep backward compatibility
  double get totalPrice => total;

  CartLine copyWith({
    Item? item,
    int? quantity,
    double? discount,
  }) {
    return CartLine(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item.toJson(),
      'quantity': quantity,
      'discount': discount,
    };
  }

  factory CartLine.fromJson(Map<String, dynamic> json) {
    return CartLine(
      item: Item.fromJson(json['item'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object> get props => [item, quantity, discount];
}
