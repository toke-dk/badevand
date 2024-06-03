extension MyStringExtension on String {
  double get commaDecimalToDouble => double.parse(replaceAll(',', '.'));
}