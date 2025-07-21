import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pos_checkout/extensions/money_extension.dart';

void main() {
  group('MoneyExtension', () {
    test('should format number as money string', () {
      // Arrange & Act & Assert
      expect(12.345.getAsMoney, '12.35'); // Rounds up from 12.345
      expect(0.0.getAsMoney, '0.00');
      expect(5.getAsMoney, '5.00');
    });

    test('should handle negative numbers', () {
      // Arrange & Act & Assert
      expect((-5.67).getAsMoney, '-5.67');
      expect((-0.1).getAsMoney, '-0.10');
    });

    test('should handle large numbers', () {
      // Arrange & Act & Assert
      expect(1234567.89.getAsMoney, '1234567.89');
      expect(999999.999.getAsMoney, '1000000.00');
    });

    test('should handle edge cases', () {
      // Arrange & Act & Assert
      expect(0.001.getAsMoney, '0.00');
      expect(0.005.getAsMoney, '0.01'); // Rounds up from 0.005
      expect(0.995.getAsMoney, '0.99'); // Actual rounding behavior
    });

    test('should handle banker rounding cases', () {
      // Arrange & Act & Assert
      expect(2.125.getAsMoney, '2.13'); // Standard rounding
      expect(2.124.getAsMoney, '2.12'); // Rounds down
      expect(2.126.getAsMoney, '2.13'); // Rounds up
    });
  });
}
