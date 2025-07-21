import 'package:equatable/equatable.dart';
import 'cart_line.dart';

class Receipt extends Equatable {
  final String id;
  final List<CartLine> items;
  final double totalAmount;
  final DateTime timestamp;

  const Receipt({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as String,
      items: (json['items'] as List)
          .map((item) => CartLine.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  List<Object> get props => [id, items, totalAmount, timestamp];
}
