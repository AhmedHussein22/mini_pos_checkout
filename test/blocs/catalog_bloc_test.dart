import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pos_checkout/blocs/catalog/catalog_bloc.dart';
import 'package:mini_pos_checkout/blocs/catalog/catalog_event.dart';
import 'package:mini_pos_checkout/blocs/catalog/catalog_state.dart';
import 'package:mini_pos_checkout/models/item.dart';
import 'package:mocktail/mocktail.dart';

class MockAssetBundle extends Mock implements AssetBundle {}

void main() {
  group('CatalogBloc', () {
    late CatalogBloc catalogBloc;
    late MockAssetBundle mockAssetBundle;

    setUp(() {
      mockAssetBundle = MockAssetBundle();
      catalogBloc = CatalogBloc(assetBundle: mockAssetBundle);
    });

    tearDown(() {
      catalogBloc.close();
    });

    test('initial state should be CatalogInitial', () {
      // Assert
      expect(catalogBloc.state, const CatalogInitial());
    });

    blocTest<CatalogBloc, CatalogState>(
      'emits [CatalogLoading, CatalogLoaded] when LoadCatalog is added',
      build: () {
        when(() => mockAssetBundle.loadString('assets/catalog.json')).thenAnswer(
          (_) async => jsonEncode([
            {'id': 'p01', 'name': 'Coffee', 'price': 2.50},
            {'id': 'p02', 'name': 'Bagel', 'price': 3.20},
          ]),
        );
        return catalogBloc;
      },
      act: (bloc) => bloc.add(LoadCatalog()),
      expect: () => [
        const CatalogLoading(),
        const CatalogLoaded([
          Item(id: 'p01', name: 'Coffee', price: 2.50),
          Item(id: 'p02', name: 'Bagel', price: 3.20),
        ]),
      ],
    );

    blocTest<CatalogBloc, CatalogState>(
      'emits [CatalogLoading, CatalogError] when loading fails',
      build: () {
        when(() => mockAssetBundle.loadString('assets/catalog.json')).thenThrow(Exception('Failed to load'));
        return catalogBloc;
      },
      act: (bloc) => bloc.add(LoadCatalog()),
      expect: () => [
        const CatalogLoading(),
        const CatalogError('Failed to load catalog: Exception: Failed to load'),
      ],
    );

    blocTest<CatalogBloc, CatalogState>(
      'emits CatalogLoaded when RefreshCatalog is added',
      build: () {
        when(() => mockAssetBundle.loadString('assets/catalog.json')).thenAnswer(
          (_) async => jsonEncode([
            {'id': 'p01', 'name': 'Coffee', 'price': 2.50},
          ]),
        );
        return catalogBloc;
      },
      act: (bloc) => bloc.add(RefreshCatalog()),
      expect: () => [
        const CatalogLoaded([
          Item(id: 'p01', name: 'Coffee', price: 2.50),
        ]),
      ],
    );

    blocTest<CatalogBloc, CatalogState>(
      'emits CatalogError when RefreshCatalog fails',
      build: () {
        when(() => mockAssetBundle.loadString('assets/catalog.json')).thenThrow(Exception('Network error'));
        return catalogBloc;
      },
      act: (bloc) => bloc.add(RefreshCatalog()),
      expect: () => [
        const CatalogError('Failed to refresh catalog: Exception: Network error'),
      ],
    );

    blocTest<CatalogBloc, CatalogState>(
      'should maintain same items count after refresh',
      build: () {
        when(() => mockAssetBundle.loadString('assets/catalog.json')).thenAnswer(
          (_) async => jsonEncode([
            {'id': 'p01', 'name': 'Coffee', 'price': 2.50},
            {'id': 'p02', 'name': 'Bagel', 'price': 3.20},
          ]),
        );
        return catalogBloc;
      },
      act: (bloc) => bloc.add(LoadCatalog()),
      expect: () => [
        const CatalogLoading(),
        const CatalogLoaded([
          Item(id: 'p01', name: 'Coffee', price: 2.50),
          Item(id: 'p02', name: 'Bagel', price: 3.20),
        ]),
      ],
      verify: (bloc) {
        final state = bloc.state;
        expect(state, isA<CatalogLoaded>());
        final loadedState = state as CatalogLoaded;
        expect(loadedState.items.length, 2);
      },
    );

    blocTest<CatalogBloc, CatalogState>(
      'should load same items after refresh from loaded state',
      build: () {
        when(() => mockAssetBundle.loadString('assets/catalog.json')).thenAnswer(
          (_) async => jsonEncode([
            {'id': 'p01', 'name': 'Coffee', 'price': 2.50},
            {'id': 'p02', 'name': 'Bagel', 'price': 3.20},
          ]),
        );
        return CatalogBloc(assetBundle: mockAssetBundle);
      },
      seed: () => const CatalogLoaded([
        Item(id: 'p03', name: 'Tea', price: 1.50),
      ]),
      act: (bloc) => bloc.add(RefreshCatalog()),
      expect: () => [
        const CatalogLoaded([
          Item(id: 'p01', name: 'Coffee', price: 2.50),
          Item(id: 'p02', name: 'Bagel', price: 3.20),
        ]),
      ],
      verify: (bloc) {
        final state = bloc.state;
        expect(state, isA<CatalogLoaded>());
        final loadedState = state as CatalogLoaded;
        expect(loadedState.items.length, 2);
        expect(loadedState.items[0].name, 'Coffee');
        expect(loadedState.items[1].name, 'Bagel');
      },
    );

    test('should handle catalog loading with real data structure', () async {
      // Arrange
      when(() => mockAssetBundle.loadString('assets/catalog.json')).thenAnswer(
        (_) async => jsonEncode([
          {'id': 'p01', 'name': 'Coffee', 'price': 2.50},
          {'id': 'p19', 'name': 'Burger', 'price': 7.20},
        ]),
      );

      // Act
      catalogBloc.add(LoadCatalog());
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      final state = catalogBloc.state;
      expect(state, isA<CatalogLoaded>());
      final loadedState = state as CatalogLoaded;

      final coffeeItem = loadedState.items.firstWhere((item) => item.id == 'p01');
      final burgerItem = loadedState.items.firstWhere((item) => item.id == 'p19');

      expect(coffeeItem.name, 'Coffee');
      expect(coffeeItem.price, 2.50);
      expect(burgerItem.name, 'Burger');
      expect(burgerItem.price, 7.20);
    });

    test('CatalogLoaded state should support equality', () {
      // Arrange
      const item1 = Item(id: 'p01', name: 'Coffee', price: 2.50);
      const item2 = Item(id: 'p02', name: 'Tea', price: 2.00);

      // Act
      const state1 = CatalogLoaded([item1, item2]);
      const state2 = CatalogLoaded([item1, item2]);
      const state3 = CatalogLoaded([item1]);

      // Assert
      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('CatalogError state should support equality', () {
      // Arrange & Act
      const error1 = CatalogError('Network error');
      const error2 = CatalogError('Network error');
      const error3 = CatalogError('Different error');

      // Assert
      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });
  });
}
