import 'dart:io';
import 'dart:math' as math;
import 'package:badevand/extenstions/string_extension.dart';
import 'package:csv/csv.dart';

Future<void> main(List<String> arguments) async {
  final path = arguments[0];
  final file = File(path);
  List<List<dynamic>> rowsAsListOfValues = CsvToListConverter(
      fieldDelimiter: ";").convert(await file.readAsString());
  print(rowsAsListOfValues.skip(1).map((row) {
    String placeName = row[2].toString();
    double yCords = y2lat(row[6].toString().commaDecimalToDouble);
    return yCords;
  }).toList()[0]);
}

double y2lat(double y) {
  final pi = math.pi;
  final radToDeg = 180 / math.pi;
  final degToRad = math.pi / 180;
  final r = 6378137;
  return (2 * math.atan(math.exp(y / r)) - pi / 2) * radToDeg;
}