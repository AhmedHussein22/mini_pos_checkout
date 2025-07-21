import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../models/cart_line.dart';
import '../../models/item.dart';
import '../../models/receipt.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends HydratedBloc<CartEvent, CartState> {
  CartBloc() : super(const CartInitial()) {
    on<AddItemToCart>(_onAddItemToCart);
    on<RemoveItemFromCart>(_onRemoveItemFromCart);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<ClearCart>(_onClearCart);
    on<CheckoutCart>(_onCheckoutCart);
  }

  void _onAddItemToCart(
    AddItemToCart event,
    Emitter<CartState> emit,
  ) {
    final currentState = state;
    if (currentState is CartLoaded) {
      final items = List<CartLine>.from(currentState.items);
      final existingIndex = items.indexWhere((line) => line.item.id == event.item.id);
      
      if (existingIndex != -1) {
        items[existingIndex] = items[existingIndex].copyWith(
          quantity: items[existingIndex].quantity + 1,
        );
      } else {
        items.add(CartLine(item: event.item, quantity: 1));
      }
      
      final totalAmount = items.fold(0.0, (sum, line) => sum + line.totalPrice);
      emit(CartLoaded(items: items, totalAmount: totalAmount));
    } else {
      final items = [CartLine(item: event.item, quantity: 1)];
      emit(CartLoaded(items: items, totalAmount: event.item.price));
    }
  }

  void _onRemoveItemFromCart(
    RemoveItemFromCart event,
    Emitter<CartState> emit,
  ) {
    final currentState = state;
    if (currentState is CartLoaded) {
      final items = currentState.items
          .where((line) => line.item.id != event.itemId)
          .toList();
      
      final totalAmount = items.fold(0.0, (sum, line) => sum + line.totalPrice);
      emit(CartLoaded(items: items, totalAmount: totalAmount));
    }
  }

  void _onUpdateItemQuantity(
    UpdateItemQuantity event,
    Emitter<CartState> emit,
  ) {
    final currentState = state;
    if (currentState is CartLoaded) {
      final items = currentState.items.map((line) {
        if (line.item.id == event.itemId) {
          return line.copyWith(quantity: event.quantity);
        }
        return line;
      }).toList();
      
      final totalAmount = items.fold(0.0, (sum, line) => sum + line.totalPrice);
      emit(CartLoaded(items: items, totalAmount: totalAmount));
    }
  }

  void _onClearCart(
    ClearCart event,
    Emitter<CartState> emit,
  ) {
    emit(const CartLoaded(items: [], totalAmount: 0.0));
  }

  void _onCheckoutCart(
    CheckoutCart event,
    Emitter<CartState> emit,
  ) {
    final currentState = state;
    if (currentState is CartLoaded && currentState.items.isNotEmpty) {
      emit(CartCheckingOut(
        items: currentState.items,
        totalAmount: currentState.totalAmount,
      ));
      
      final receipt = Receipt(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        items: currentState.items,
        totalAmount: currentState.totalAmount,
        timestamp: DateTime.now(),
      );
      
      emit(CartCheckedOut(receipt));
    }
  }

  @override
  CartState? fromJson(Map<String, dynamic> json) {
    try {
      final items = (json['items'] as List?)
          ?.map((item) => CartLine.fromJson(item as Map<String, dynamic>))
          .toList() ?? [];
      final totalAmount = (json['totalAmount'] as num?)?.toDouble() ?? 0.0;
      
      return CartLoaded(items: items, totalAmount: totalAmount);
    } catch (_) {
      return const CartInitial();
    }
  }

  @override
  Map<String, dynamic>? toJson(CartState state) {
    if (state is CartLoaded) {
      return {
        'items': state.items.map((item) => item.toJson()).toList(),
        'totalAmount': state.totalAmount,
      };
    }
    return null;
  }
}
