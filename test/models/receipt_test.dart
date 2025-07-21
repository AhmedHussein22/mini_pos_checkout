import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pos_checkout/models/cart_line.dart';
import 'package:mini_pos_checkout/models/item.dart';
import 'package:mini_pos_checkout/models/receipt.dart';

void main() {
  group('Receipt', () {
    test('should create Receipt with correct properties', () {
      // Arrange
      final item = Item(id: 'p01', name: 'Coffee', price: 2.50);
      final cartLine = CartLine(item: item, quantity: 2, discount: 0.5);

      // Act
      final receipt = Receipt(
        lines: [cartLine],
        subtotal: 5.0,
        vat: 0.75,
        discount: 0.5,
        grandTotal: 5.25,
      );

      // Assert
      expect(receipt.lines, [cartLine]);
      expect(receipt.subtotal, 5.0);
      expect(receipt.vat, 0.75);
      expect(receipt.discount, 0.5);
      expect(receipt.grandTotal, 5.25);
    });

    test('should support value equality', () {
      // Arrange
      final item = Item(id: 'p01', name: 'Coffee', price: 2.50);
      final cartLine = CartLine(item: item, quantity: 2, discount: 0.5);

      // Act
      final receipt1 = Receipt(
        lines: [cartLine],
        subtotal: 5.0,
        vat: 0.75,
        discount: 0.5,
        grandTotal: 5.25,
      );
      final receipt2 = Receipt(
        lines: [cartLine],
        subtotal: 5.0,
        vat: 0.75,
        discount: 0.5,
        grandTotal: 5.25,
      );
      final receipt3 = Receipt(
        lines: [cartLine],
        subtotal: 6.0,
        vat: 0.9,
        discount: 0.5,
        grandTotal: 6.4,
      );

      // Assert
      expect(receipt1, equals(receipt2));
      expect(receipt1, isNot(equals(receipt3)));
    });

    test('should create from JSON correctly', () {
      // Arrange
      final json = {
        'lines': [
          {
            'item': {'id': 'p01', 'name': 'Coffee', 'price': 2.50},
            'quantity': 2,
            'discount': 0.5,
          }
        ],
        'subtotal': 5.0,
        'vat': 0.75,
        'discount': 0.5,
        'grandTotal': 5.25,
      };

      // Act
      final receipt = Receipt.fromJson(json);

      // Assert
      expect(receipt.lines.length, 1);
      expect(receipt.subtotal, 5.0);
      expect(receipt.vat, 0.75);
      expect(receipt.discount, 0.5);
      expect(receipt.grandTotal, 5.25);
    });

    test('should convert to JSON correctly', () {
      // Arrange
      final item = Item(id: 'p01', name: 'Coffee', price: 2.50);
      final cartLine = CartLine(item: item, quantity: 2, discount: 0.5);
      final receipt = Receipt(
        lines: [cartLine],
        subtotal: 5.0,
        vat: 0.75,
        discount: 0.5,
        grandTotal: 5.25,
      );

      // Act
      final json = receipt.toJson();

      // Assert
      expect(json['lines'].length, 1);
      expect(json['subtotal'], 5.0);
      expect(json['vat'], 0.75);
      expect(json['discount'], 0.5);
      expect(json['grandTotal'], 5.25);
    });

    test('should handle empty cart lines', () {
      // Arrange & Act
      final receipt = Receipt(
        lines: [],
        subtotal: 0.0,
        vat: 0.0,
        discount: 0.0,
        grandTotal: 0.0,
      );

      // Assert
      expect(receipt.lines, isEmpty);
      expect(receipt.grandTotal, 0.0);
    });

    test('should handle multiple cart lines', () {
      // Arrange
      final item1 = Item(id: 'p01', name: 'Coffee', price: 2.50);
      final item2 = Item(id: 'p02', name: 'Tea', price: 2.00);
      final cartLine1 = CartLine(item: item1, quantity: 2, discount: 0.5);
      final cartLine2 = CartLine(item: item2, quantity: 1, discount: 0.0);

      // Act
      final receipt = Receipt(
        lines: [cartLine1, cartLine2],
        subtotal: 7.0,
        vat: 1.05,
        discount: 0.5,
        grandTotal: 7.55,
      );

      // Assert
      expect(receipt.lines.length, 2);
      expect(receipt.lines[0].item.name, 'Coffee');
      expect(receipt.lines[1].item.name, 'Tea');
      expect(receipt.grandTotal, 7.55);
    });
  });
}
