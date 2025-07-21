import 'package:equatable/equatable.dart';
import 'package:mini_pos_checkout/models/cart_line.dart';

/// Represents the final receipt after checkout.
class Receipt extends Equatable {
  final List<CartLine> lines;
  final double subtotal;
  final double vat;
  final double discount;
  final double grandTotal;

  const Receipt({
    required this.lines,
    required this.subtotal,
    required this.vat,
    required this.discount,
    required this.grandTotal,
  });

  // Keep backward compatibility
  String get id => DateTime.now().millisecondsSinceEpoch.toString();
  List<CartLine> get items => lines;
  double get totalAmount => grandTotal;
  DateTime get timestamp => DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'lines': lines.map((line) => line.toJson()).toList(),
      'subtotal': subtotal,
      'vat': vat,
      'discount': discount,
      'grandTotal': grandTotal,
    };
  }

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      lines: (json['lines'] as List).map((line) => CartLine.fromJson(line as Map<String, dynamic>)).toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      vat: (json['vat'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      grandTotal: (json['grandTotal'] as num).toDouble(),
    );
  }

  @override
  List<Object> get props => [lines, subtotal, vat, discount, grandTotal];
}
