import 'package:equatable/equatable.dart';
import '../../models/cart_line.dart';
import '../../models/receipt.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoaded extends CartState {
  final List<CartLine> items;
  final double totalAmount;

  const CartLoaded({
    required this.items,
    required this.totalAmount,
  });

  @override
  List<Object> get props => [items, totalAmount];
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
