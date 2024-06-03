import 'dart:io';
import 'dart:math' as math;
import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:badevand/extenstions/string_extension.dart';
import 'package:csv/csv.dart';
import 'package:coordinate_converter/coordinate_converter.dart';

Future<void> main(List<String> arguments) async {
  final path = arguments[0];
  final file = File(path);
  List<List<dynamic>> rowsAsListOfValues =
      CsvToListConverter(fieldDelimiter: ";")
          .convert(await file.readAsString());
  print(rowsAsListOfValues.skip(1).map((row) {
    int zone = int.parse(row[4].toString());
    double xCords = row[5].toString().commaDecimalToDouble;
    double yCords = row[6].toString().commaDecimalToDouble;

    UTMCoordinates utmCords =
        UTMCoordinates(x: xCords, y: yCords, zoneNumber: zone);

    DDCoordinates ddCords = utmCords.toDD();

    double lat = ddCords.latitude;
    double lon = ddCords.longitude;

    return "$lat $lon";
  }).toList()[6]);
}
