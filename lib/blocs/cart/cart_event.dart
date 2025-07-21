import 'package:equatable/equatable.dart';
import '../../models/item.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class AddItemToCart extends CartEvent {
  final Item item;

  const AddItemToCart(this.item);

  @override
  List<Object> get props => [item];
}

class RemoveItemFromCart extends CartEvent {
  final String itemId;

  const RemoveItemFromCart(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class UpdateItemQuantity extends CartEvent {
  final String itemId;
  final int quantity;

  const UpdateItemQuantity(this.itemId, this.quantity);

  @override
  List<Object> get props => [itemId, quantity];
}

class ClearCart extends CartEvent {
  const ClearCart();
}

class CheckoutCart extends CartEvent {
  const CheckoutCart();
}
