# Mini POS Checkout Core

A headless checkout engine implemented using Flutter, BLoC, and pure Dart.

## Flutter & Dart Versions

- Flutter: 3.27.3
- Dart: 3.4.0

## Features

### Must-Have Features ✅

- **CatalogBloc**: Loads product catalog from JSON assets
- **CartBloc**: Manages cart operations (add/remove items, quantities, discounts)
- **Business Rules**: 15% VAT calculation on all items
- **Immutable State**: All models are immutable using Equatable
- **Unit Tests**: Comprehensive test coverage for all components

### Nice-to-Have Features ✅

- **Undo/Redo**: Full undo/redo functionality for cart operations
- **Hydrated BLoC**: Cart state persistence across app restarts
- **100% Test Coverage**: All business logic thoroughly tested
- **Money Extension**: Currency formatting utilities

## Architecture

The project follows Clean Architecture principles with BLoC pattern:

```
lib/
├── blocs/
│   ├── catalog/         # Catalog management
│   └── cart/           # Cart operations with undo/redo
├── models/             # Immutable data models
│   ├── item.dart
│   ├── cart_line.dart
│   └── receipt.dart
└── extensions/         # Utility extensions
    └── money_extension.dart

test/
├── blocs/              # BLoC unit tests
├── models/             # Model unit tests
└── extensions/         # Extension unit tests
```

## How to Run Tests

```bash
flutter pub get
flutter test
```

To run with coverage:

```bash
flutter test --coverage
```

To run analysis:

```bash
dart analyze --fatal-warnings
```

## Usage Example

```dart
// Initialize storage for HydratedBloc
HydratedBloc.storage = await HydratedStorage.build();

// Create catalog bloc
final catalogBloc = CatalogBloc(assetBundle: rootBundle);
catalogBloc.add(LoadCatalog());

// Create cart bloc with persistence
final cartBloc = CartBloc();

// Add items to cart
cartBloc.add(AddItem(item: coffeeItem));
cartBloc.add(UpdateQuantity(item: coffeeItem, quantity: 2));
cartBloc.add(ApplyDiscount(item: coffeeItem, discount: 1.0));

// Undo/Redo operations
cartBloc.add(Undo());
cartBloc.add(Redo());

// Checkout
cartBloc.add(Checkout());
```

## Business Rules

- **VAT**: 15% VAT is automatically applied to all items
- **Discounts**: Can be applied per cart line
- **Total Calculation**: `(Subtotal + VAT) - Discounts`
- **Minimum Total**: Cart total cannot go below 0.00

## Time Spent

**Total time: ~4 hours**

- ✅ Completed all must-have requirements: CatalogBloc, CartBloc, business rules (15% VAT), immutable state, unit tests
- ✅ Completed all nice-to-have requirements: Undo/Redo, Hydrated BLoC, 100% test coverage, Money extension
- ✅ No skipped items

## Notes

- The project uses BLoC pattern for state management
- All code is immutable and passes `dart analyze --fatal-warnings`
- Catalog is loaded from `assets/catalog.json`
- Cart state persists across app restarts using HydratedBloc
- Comprehensive unit tests ensure reliability and maintainability
- TDD approach was followed for all implementations
