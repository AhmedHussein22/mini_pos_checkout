import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pos_checkout/models/cart_line.dart';
import 'package:mini_pos_checkout/models/item.dart';

void main() {
  group('CartLine', () {
    test('should create CartLine with correct properties', () {
      // Arrange
      final item = Item(id: 'p01', name: 'Coffee', price: 2.50);

      // Act
      final cartLine = CartLine(item: item, quantity: 2, discount: 0.0);

      // Assert
      expect(cartLine.item, item);
      expect(cartLine.quantity, 2);
      expect(cartLine.discount, 0.0);
      expect(cartLine.total, 5.0);
    });

    test('should support value equality', () {
      // Arrange
      final item = Item(id: 'p01', name: 'Coffee', price: 2.50);

      // Act
      final cartLine1 = CartLine(item: item, quantity: 2, discount: 0.0);
      final cartLine2 = CartLine(item: item, quantity: 2, discount: 0.0);
      final cartLine3 = CartLine(item: item, quantity: 3, discount: 0.0);

      // Assert
      expect(cartLine1, equals(cartLine2));
      expect(cartLine1, isNot(equals(cartLine3)));
    });

    test('should calculate total correctly with discount', () {
      // Arrange
      final item = Item(id: 'p01', name: 'Coffee', price: 2.50);

      // Act
      final cartLine = CartLine(item: item, quantity: 4, discount: 2.0);

      // Assert
      expect(cartLine.total, 8.0); // (2.50 * 4) - 2.0 = 8.0
    });

    test('should handle zero quantity', () {
      // Arrange
      final item = Item(id: 'p01', name: 'Coffee', price: 2.50);

      // Act
      final cartLine = CartLine(item: item, quantity: 0, discount: 0.0);

      // Assert
      expect(cartLine.total, 0.0);
    });

    test('should handle discount larger than subtotal', () {
      // Arrange
      final item = Item(id: 'p01', name: 'Coffee', price: 2.50);

      // Act
      final cartLine = CartLine(item: item, quantity: 1, discount: 5.0);

      // Assert
      expect(cartLine.total, 0.0); // Should not go negative
    });

    test('should create from JSON correctly', () {
      // Arrange
      final json = {
        'item': {'id': 'p01', 'name': 'Coffee', 'price': 2.50},
        'quantity': 2,
        'discount': 1.0,
      };

      // Act
      final cartLine = CartLine.fromJson(json);

      // Assert
      expect(cartLine.item.id, 'p01');
      expect(cartLine.quantity, 2);
      expect(cartLine.discount, 1.0);
      expect(cartLine.total, 4.0);
    });

    test('should convert to JSON correctly', () {
      // Arrange
      final item = Item(id: 'p01', name: 'Coffee', price: 2.50);
      final cartLine = CartLine(item: item, quantity: 2, discount: 1.0);

      // Act
      final json = cartLine.toJson();

      // Assert
      expect(json['item']['id'], 'p01');
      expect(json['quantity'], 2);
      expect(json['discount'], 1.0);
    });

    test('should copy with new values', () {
      // Arrange
      final item = Item(id: 'p01', name: 'Coffee', price: 2.50);
      final originalCartLine = CartLine(item: item, quantity: 2, discount: 0.0);
      final newItem = Item(id: 'p02', name: 'Tea', price: 2.00);

      // Act
      final copiedCartLine = originalCartLine.copyWith(
        item: newItem,
        quantity: 3,
        discount: 1.0,
      );

      // Assert
      expect(copiedCartLine.item, newItem);
      expect(copiedCartLine.quantity, 3);
      expect(copiedCartLine.discount, 1.0);
      expect(originalCartLine.item, item); // Original unchanged
    });
  });
}
