import 'package:equatable/equatable.dart';
import 'package:mini_pos_checkout/models/cart_line.dart';
import 'package:mini_pos_checkout/models/receipt.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoaded extends CartState {
  final List<CartLine> lines;
  final double subtotal;
  final double vat;
  final double discount;
  final double grandTotal;

  const CartLoaded({
    required this.lines,
    required this.subtotal,
    required this.vat,
    required this.discount,
    required this.grandTotal,
  });

  // Backward compatibility
  List<CartLine> get items => lines;
  double get totalAmount => grandTotal;

  @override
  List<Object> get props => [lines, subtotal, vat, discount, grandTotal];
}

class CartCheckingOut extends CartState {
  final List<CartLine> items;
  final double totalAmount;

  const CartCheckingOut({
    required this.items,
    required this.totalAmount,
  });

  @override
  List<Object> get props => [items, totalAmount];
}

class CartCheckedOut extends CartState {
  final Receipt receipt;

  const CartCheckedOut(this.receipt);

  @override
  List<Object> get props => [receipt];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object> get props => [message];
}
