import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pos_checkout/models/item.dart';

void main() {
  group('Item Model Tests', () {
    test('should create Item with required fields', () {
      // Arrange & Act
      const item = Item(
        id: 'p01',
        name: 'Coffee',
        price: 2.50,
      );

      // Assert
      expect(item.id, 'p01');
      expect(item.name, 'Coffee');
      expect(item.price, 2.50);
      expect(item.description, null);
    });

    test('should create Item with all fields including description', () {
      // Arrange & Act
      const item = Item(
        id: 'p01',
        name: 'Coffee',
        price: 2.50,
        description: 'Fresh brewed coffee',
      );

      // Assert
      expect(item.id, 'p01');
      expect(item.name, 'Coffee');
      expect(item.price, 2.50);
      expect(item.description, 'Fresh brewed coffee');
    });

    test('should create Item from JSON without description', () {
      // Arrange
      final json = {
        'id': 'p01',
        'name': 'Coffee',
        'price': 2.50,
      };

      // Act
      final item = Item.fromJson(json);

      // Assert
      expect(item.id, 'p01');
      expect(item.name, 'Coffee');
      expect(item.price, 2.50);
      expect(item.description, null);
    });

    test('should create Item from JSON with description', () {
      // Arrange
      final json = {
        'id': 'p01',
        'name': 'Coffee',
        'price': 2.50,
        'description': 'Fresh brewed coffee',
      };

      // Act
      final item = Item.fromJson(json);

      // Assert
      expect(item.id, 'p01');
      expect(item.name, 'Coffee');
      expect(item.price, 2.50);
      expect(item.description, 'Fresh brewed coffee');
    });

    test('should handle integer price in JSON', () {
      // Arrange
      final json = {
        'id': 'p01',
        'name': 'Coffee',
        'price': 3, // Integer instead of double
      };

      // Act
      final item = Item.fromJson(json);

      // Assert
      expect(item.price, 3.0);
    });

    test('should convert Item to JSON without description', () {
      // Arrange
      const item = Item(
        id: 'p01',
        name: 'Coffee',
        price: 2.50,
      );

      // Act
      final json = item.toJson();

      // Assert
      expect(json, {
        'id': 'p01',
        'name': 'Coffee',
        'price': 2.50,
        'description': null,
      });
    });

    test('should convert Item to JSON with description', () {
      // Arrange
      const item = Item(
        id: 'p01',
        name: 'Coffee',
        price: 2.50,
        description: 'Fresh brewed coffee',
      );

      // Act
      final json = item.toJson();

      // Assert
      expect(json, {
        'id': 'p01',
        'name': 'Coffee',
        'price': 2.50,
        'description': 'Fresh brewed coffee',
      });
    });

    test('should implement equality correctly', () {
      // Arrange
      const item1 = Item(
        id: 'p01',
        name: 'Coffee',
        price: 2.50,
      );
      const item2 = Item(
        id: 'p01',
        name: 'Coffee',
        price: 2.50,
      );
      const item3 = Item(
        id: 'p02',
        name: 'Coffee',
        price: 2.50,
      );

      // Assert
      expect(item1, equals(item2));
      expect(item1, isNot(equals(item3)));
      expect(item1.hashCode, equals(item2.hashCode));
    });

    test('should handle JSON serialization roundtrip', () {
      // Arrange
      const originalItem = Item(
        id: 'p01',
        name: 'Coffee',
        price: 2.50,
        description: 'Fresh brewed coffee',
      );

      // Act
      final json = originalItem.toJson();
      final deserializedItem = Item.fromJson(json);

      // Assert
      expect(deserializedItem, equals(originalItem));
    });

    test('should handle catalog JSON format', () {
      // Arrange - Sample from actual catalog
      final catalogItems = [
        {"id": "p01", "name": "Coffee", "price": 2.50},
        {"id": "p02", "name": "Bagel", "price": 3.20},
      ];

      // Act
      final items = catalogItems.map((json) => Item.fromJson(json)).toList();

      // Assert
      expect(items.length, 2);
      expect(items[0].id, 'p01');
      expect(items[0].name, 'Coffee');
      expect(items[0].price, 2.50);
      expect(items[1].id, 'p02');
      expect(items[1].name, 'Bagel');
      expect(items[1].price, 3.20);
    });

    test('should handle edge cases in pricing', () {
      // Arrange & Act
      const zeroPrice = Item(id: 'p01', name: 'Free Sample', price: 0.0);
      const highPrice = Item(id: 'p02', name: 'Premium Item', price: 999.99);

      // Assert
      expect(zeroPrice.price, 0.0);
      expect(highPrice.price, 999.99);
    });

    test('should handle special characters in name', () {
      // Arrange & Act
      const item = Item(
        id: 'p01',
        name: 'Café Latté & Croissant™',
        price: 5.50,
      );

      // Assert
      expect(item.name, 'Café Latté & Croissant™');
    });
  });
}
