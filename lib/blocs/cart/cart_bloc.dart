import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mini_pos_checkout/models/cart_line.dart';
import 'package:mini_pos_checkout/models/item.dart';
import 'package:mini_pos_checkout/models/receipt.dart';

import 'cart_event.dart';
import 'cart_state.dart';

/// Manages the cart operations including add/remove items, discounts, and checkout.
class CartBloc extends HydratedBloc<CartEvent, CartState> {
  CartBloc() : super(const CartLoaded(lines: [], subtotal: 0.0, vat: 0.0, discount: 0.0, grandTotal: 0.0)) {
    on<AddItem>(_onAddItem);
    on<RemoveItem>(_onRemoveItem);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ApplyDiscount>(_onApplyDiscount);
    on<Checkout>(_onCheckout);
    on<Undo>(_onUndo);
    on<Redo>(_onRedo);
  }

  static const double vatRate = 0.15;
  final List<CartState> _history = [];
  int _historyIndex = -1;

  @override
  CartState? fromJson(Map<String, dynamic> json) {
    try {
      final lines = (json['lines'] as List)
          .map((line) => CartLine(
                item: Item(
                  id: line['item']['id'],
                  name: line['item']['name'],
                  price: line['item']['price'],
                ),
                quantity: line['quantity'],
                discount: line['discount'] ?? 0.0,
              ))
          .toList();
      return CartLoaded(
        lines: lines,
        subtotal: json['subtotal'],
        vat: json['vat'],
        discount: json['discount'],
        grandTotal: json['grandTotal'],
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(CartState state) {
    if (state is CartLoaded) {
      return {
        'lines': state.lines
            .map((line) => {
                  'item': {'id': line.item.id, 'name': line.item.name, 'price': line.item.price},
                  'quantity': line.quantity,
                  'discount': line.discount,
                })
            .toList(),
        'subtotal': state.subtotal,
        'vat': state.vat,
        'discount': state.discount,
        'grandTotal': state.grandTotal,
      };
    }
    return null;
  }

  @override
  void onChange(Change<CartState> change) {
    super.onChange(change);
    // Initialize history with seeded state if it's the first CartLoaded state
    if (change.nextState is CartLoaded && _history.isEmpty) {
      _history.add(change.nextState);
      _historyIndex = 0;
    }
  }

  void _saveToHistory(CartState state) {
    // Only save CartLoaded states to history
    if (state is! CartLoaded) return;

    // Initialize history if empty (for when state is set via seed)
    if (_history.isEmpty) {
      _history.add(state);
      _historyIndex = 0;
      return;
    }

    // Remove any future history if we're not at the end
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    _history.add(state);
    _historyIndex++;

    // Keep history size manageable
    if (_history.length > 10) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  Future<void> _onAddItem(AddItem event, Emitter<CartState> emit) async {
    final currentState = state as CartLoaded;
    _saveToHistory(currentState);

    final newLines = List<CartLine>.from(currentState.lines);
    final index = newLines.indexWhere((line) => line.item.id == event.item.id);

    if (index >= 0) {
      newLines[index] = newLines[index].copyWith(quantity: newLines[index].quantity + 1);
    } else {
      newLines.add(CartLine(item: event.item, quantity: 1));
    }

    final newState = _calculateTotals(newLines);
    emit(newState);

    // Save the new state to history for redo functionality
    _saveToHistory(newState);
  }

  Future<void> _onRemoveItem(RemoveItem event, Emitter<CartState> emit) async {
    final currentState = state as CartLoaded;
    _saveToHistory(currentState);
    final newLines = List<CartLine>.from(currentState.lines)..removeWhere((line) => line.item.id == event.item.id);
    final newState = _calculateTotals(newLines);
    emit(newState);
  }

  Future<void> _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) async {
    final currentState = state as CartLoaded;
    _saveToHistory(currentState);
    final newLines = List<CartLine>.from(currentState.lines);
    final index = newLines.indexWhere((line) => line.item.id == event.item.id);
    if (index >= 0 && event.quantity > 0) {
      newLines[index] = newLines[index].copyWith(quantity: event.quantity);
    } else if (index >= 0) {
      newLines.removeAt(index);
    }
    final newState = _calculateTotals(newLines);
    emit(newState);
  }

  Future<void> _onApplyDiscount(ApplyDiscount event, Emitter<CartState> emit) async {
    final currentState = state as CartLoaded;
    _saveToHistory(currentState);
    final newLines = List<CartLine>.from(currentState.lines);
    final index = newLines.indexWhere((line) => line.item.id == event.item.id);
    if (index >= 0) {
      newLines[index] = newLines[index].copyWith(discount: event.discount);
    }
    final newState = _calculateTotals(newLines);
    emit(newState);
  }

  Future<void> _onCheckout(Checkout event, Emitter<CartState> emit) async {
    final currentState = state as CartLoaded;
    emit(CartCheckedOut(Receipt(
      lines: currentState.lines,
      subtotal: currentState.subtotal,
      vat: currentState.vat,
      discount: currentState.discount,
      grandTotal: currentState.grandTotal,
    )));
    final newState = _calculateTotals([]);
    _saveToHistory(newState);
    emit(newState);
  }

  Future<void> _onUndo(Undo event, Emitter<CartState> emit) async {
    if (_historyIndex > 0) {
      _historyIndex--;
      emit(_history[_historyIndex]);
    }
  }

  Future<void> _onRedo(Redo event, Emitter<CartState> emit) async {
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      emit(_history[_historyIndex]);
    }
  }

  CartLoaded _calculateTotals(List<CartLine> lines) {
    final subtotal = double.parse(lines.fold(0.0, (sum, line) => sum + line.item.price * line.quantity).toStringAsFixed(2));
    final discount = double.parse(lines.fold(0.0, (sum, line) => sum + line.discount).toStringAsFixed(2));
    final vat = double.parse((subtotal * vatRate).toStringAsFixed(2));
    final grandTotal = double.parse((subtotal + vat - discount).toStringAsFixed(2));
    return CartLoaded(
      lines: lines,
      subtotal: subtotal,
      vat: vat,
      discount: discount,
      grandTotal: grandTotal,
    );
  }
}
