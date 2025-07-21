import 'package:equatable/equatable.dart';
import 'package:mini_pos_checkout/models/item.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class AddItem extends CartEvent {
  const AddItem({required this.item});

  final Item item;

  @override
  List<Object> get props => [item];
}

class RemoveItem extends CartEvent {
  const RemoveItem({required this.item});

  final Item item;

  @override
  List<Object> get props => [item];
}

class UpdateQuantity extends CartEvent {
  const UpdateQuantity({required this.item, required this.quantity});

  final Item item;
  final int quantity;

  @override
  List<Object> get props => [item, quantity];
}

class ApplyDiscount extends CartEvent {
  const ApplyDiscount({required this.item, required this.discount});

  final Item item;
  final double discount;

  @override
  List<Object> get props => [item, discount];
}

class Checkout extends CartEvent {
  const Checkout();
}

class Undo extends CartEvent {
  const Undo();
}

class Redo extends CartEvent {
  const Redo();
}

// Keep backward compatibility
class AddItemToCart extends CartEvent {
  const AddItemToCart(this.item);

  final Item item;

  @override
  List<Object> get props => [item];
}

class RemoveItemFromCart extends CartEvent {
  const RemoveItemFromCart(this.itemId);

  final String itemId;

  @override
  List<Object> get props => [itemId];
}

class UpdateItemQuantity extends CartEvent {
  const UpdateItemQuantity(this.itemId, this.quantity);

  final String itemId;
  final int quantity;

  @override
  List<Object> get props => [itemId, quantity];
}

class ClearCart extends CartEvent {
  const ClearCart();
}

class CheckoutCart extends CartEvent {
  const CheckoutCart();
}
