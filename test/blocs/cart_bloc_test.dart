import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mini_pos_checkout/blocs/cart/cart_bloc.dart';
import 'package:mini_pos_checkout/blocs/cart/cart_event.dart';
import 'package:mini_pos_checkout/blocs/cart/cart_state.dart';
import 'package:mini_pos_checkout/models/cart_line.dart';
import 'package:mini_pos_checkout/models/item.dart';
import 'package:mini_pos_checkout/models/receipt.dart';
import 'package:mocktail/mocktail.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  group('CartBloc', () {
    late CartBloc cartBloc;
    late MockStorage mockStorage;

    setUpAll(() {
      mockStorage = MockStorage();
      when(() => mockStorage.write(any(), any())).thenAnswer((_) async {});
      when(() => mockStorage.read(any())).thenReturn(null);
      HydratedBloc.storage = mockStorage;
    });

    setUp(() {
      cartBloc = CartBloc();
    });

    tearDown(() {
      cartBloc.close();
    });

    blocTest<CartBloc, CartState>(
      'emits [CartLoaded] with updated lines when AddItem is added',
      build: () => cartBloc,
      act: (bloc) {
        // Arrange
        final item = Item(id: 'p01', name: 'Coffee', price: 2.50);

        // Act
        bloc.add(AddItem(item: item));
      },
      expect: () => [
        // Assert
        CartLoaded(
          lines: [CartLine(item: Item(id: 'p01', name: 'Coffee', price: 2.50), quantity: 1)],
          subtotal: 2.50,
          vat: 0.38,
          discount: 0.0,
          grandTotal: 2.88,
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoaded] with updated quantity when UpdateQuantity is added',
      build: () => cartBloc,
      seed: () {
        // Arrange
        final item = Item(id: 'p01', name: 'Coffee', price: 2.50);
        return CartLoaded(
          lines: [CartLine(item: item, quantity: 1)],
          subtotal: 2.50,
          vat: 0.38,
          discount: 0.0,
          grandTotal: 2.88,
        );
      },
      act: (bloc) {
        // Arrange
        final item = Item(id: 'p01', name: 'Coffee', price: 2.50);

        // Act
        bloc.add(UpdateQuantity(item: item, quantity: 2));
      },
      expect: () => [
        // Assert
        CartLoaded(
          lines: [CartLine(item: Item(id: 'p01', name: 'Coffee', price: 2.50), quantity: 2)],
          subtotal: 5.0,
          vat: 0.75,
          discount: 0.0,
          grandTotal: 5.75,
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoaded] with updated discount when ApplyDiscount is added',
      build: () => cartBloc,
      seed: () {
        // Arrange
        final item = Item(id: 'p01', name: 'Coffee', price: 2.50);
        return CartLoaded(
          lines: [CartLine(item: item, quantity: 2)],
          subtotal: 5.0,
          vat: 0.75,
          discount: 0.0,
          grandTotal: 5.75,
        );
      },
      act: (bloc) {
        // Arrange
        final item = Item(id: 'p01', name: 'Coffee', price: 2.50);

        // Act
        bloc.add(ApplyDiscount(item: item, discount: 1.0));
      },
      expect: () => [
        // Assert
        CartLoaded(
          lines: [CartLine(item: Item(id: 'p01', name: 'Coffee', price: 2.50), quantity: 2, discount: 1.0)],
          subtotal: 5.0,
          vat: 0.75,
          discount: 1.0,
          grandTotal: 4.75,
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoaded] with empty lines when RemoveItem is added',
      build: () => cartBloc,
      seed: () {
        // Arrange
        final item = Item(id: 'p01', name: 'Coffee', price: 2.50);
        return CartLoaded(
          lines: [CartLine(item: item, quantity: 1)],
          subtotal: 2.50,
          vat: 0.38,
          discount: 0.0,
          grandTotal: 2.88,
        );
      },
      act: (bloc) {
        // Arrange
        final item = Item(id: 'p01', name: 'Coffee', price: 2.50);

        // Act
        bloc.add(RemoveItem(item: item));
      },
      expect: () => [
        // Assert
        CartLoaded(
          lines: [],
          subtotal: 0.0,
          vat: 0.0,
          discount: 0.0,
          grandTotal: 0.0,
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartCheckedOut] with correct receipt when Checkout is added',
      build: () => cartBloc,
      seed: () {
        // Arrange
        final item = Item(id: 'p01', name: 'Coffee', price: 2.50);
        return CartLoaded(
          lines: [CartLine(item: item, quantity: 2, discount: 1.0)],
          subtotal: 5.0,
          vat: 0.75,
          discount: 1.0,
          grandTotal: 4.75,
        );
      },
      act: (bloc) {
        // Act
        bloc.add(Checkout());
      },
      expect: () => [
        // Assert
        CartCheckedOut(
          Receipt(
            lines: [CartLine(item: Item(id: 'p01', name: 'Coffee', price: 2.50), quantity: 2, discount: 1.0)],
            subtotal: 5.0,
            vat: 0.75,
            discount: 1.0,
            grandTotal: 4.75,
          ),
        ),
        CartLoaded(lines: [], subtotal: 0.0, vat: 0.0, discount: 0.0, grandTotal: 0.0),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits previous state when Undo is added',
      build: () => cartBloc,
      seed: () {
        // Arrange
        final item = Item(id: 'p01', name: 'Coffee', price: 2.50);
        return CartLoaded(
          lines: [CartLine(item: item, quantity: 2)],
          subtotal: 5.0,
          vat: 0.75,
          discount: 0.0,
          grandTotal: 5.75,
        );
      },
      act: (bloc) {
        // Arrange
        final item = Item(id: 'p01', name: 'Coffee', price: 2.50);

        // Act
        bloc.add(AddItem(item: item)); // This will save previous state to history
      },
      expect: () => [
        // Assert
        CartLoaded(
          lines: [CartLine(item: Item(id: 'p01', name: 'Coffee', price: 2.50), quantity: 3)],
          subtotal: 7.5,
          vat: 1.13,
          discount: 0.0,
          grandTotal: 8.63,
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'can undo after adding item',
      build: () => cartBloc,
      seed: () {
        // Arrange
        final item = Item(id: 'p01', name: 'Coffee', price: 2.50);
        return CartLoaded(
          lines: [CartLine(item: item, quantity: 2)],
          subtotal: 5.0,
          vat: 0.75,
          discount: 0.0,
          grandTotal: 5.75,
        );
      },
      act: (bloc) {
        // Arrange
        final item = Item(id: 'p01', name: 'Coffee', price: 2.50);

        // Act
        bloc.add(AddItem(item: item)); // Add item
        bloc.add(Undo()); // Undo the addition
      },
      expect: () => [
        // Assert
        CartLoaded(
          lines: [CartLine(item: Item(id: 'p01', name: 'Coffee', price: 2.50), quantity: 3)],
          subtotal: 7.5,
          vat: 1.13,
          discount: 0.0,
          grandTotal: 8.63,
        ),
        CartLoaded(
          lines: [CartLine(item: Item(id: 'p01', name: 'Coffee', price: 2.50), quantity: 2)],
          subtotal: 5.0,
          vat: 0.75,
          discount: 0.0,
          grandTotal: 5.75,
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'can redo after undo',
      build: () => cartBloc,
      seed: () {
        // Arrange
        final item = Item(id: 'p01', name: 'Coffee', price: 2.50);
        return CartLoaded(
          lines: [CartLine(item: item, quantity: 2)],
          subtotal: 5.0,
          vat: 0.75,
          discount: 0.0,
          grandTotal: 5.75,
        );
      },
      act: (bloc) {
        // Arrange
        final item = Item(id: 'p01', name: 'Coffee', price: 2.50);

        // Act
        bloc.add(AddItem(item: item)); // Add item
        bloc.add(Undo()); // Undo
        bloc.add(Redo()); // Redo
      },
      expect: () => [
        // Assert
        CartLoaded(
          lines: [CartLine(item: Item(id: 'p01', name: 'Coffee', price: 2.50), quantity: 3)],
          subtotal: 7.5,
          vat: 1.13,
          discount: 0.0,
          grandTotal: 8.63,
        ),
        CartLoaded(
          lines: [CartLine(item: Item(id: 'p01', name: 'Coffee', price: 2.50), quantity: 2)],
          subtotal: 5.0,
          vat: 0.75,
          discount: 0.0,
          grandTotal: 5.75,
        ),
        CartLoaded(
          lines: [CartLine(item: Item(id: 'p01', name: 'Coffee', price: 2.50), quantity: 3)],
          subtotal: 7.5,
          vat: 1.13,
          discount: 0.0,
          grandTotal: 8.63,
        ),
      ],
    );
  });
}
