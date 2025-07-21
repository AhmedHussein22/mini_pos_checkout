/// Extension to format numbers as money strings.
extension MoneyExtension on num {
  String get getAsMoney => toStringAsFixed(2);
}
