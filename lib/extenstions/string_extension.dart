extension MyStringExtension on String {
  double get commaDecimalToDouble => double.parse(replaceAll(',', '.'));

  String get capitalize {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}