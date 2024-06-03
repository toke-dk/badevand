import 'dart:collection';
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
  List<Map<String, dynamic>> result = rowsAsListOfValues.skip(1).map((row) {
    String name = row[2].toString();
    String municipality = row[13].toString();

    int zone = int.parse(row[4].toString());
    double xCords = row[5].toString().commaDecimalToDouble;
    double yCords = row[6].toString().commaDecimalToDouble;

    UTMCoordinates utmCords =
        UTMCoordinates(x: xCords, y: yCords, zoneNumber: zone);

    DDCoordinates ddCords = utmCords.toDD();

    double lat = ddCords.latitude;
    double lon = ddCords.longitude;

    return {"name": name, "lat": lat, "lon": lon, "municipality": municipality};
  }).toList();

  final Set names = result.map((e) => e["name"]).toSet();
  result.retainWhere((x) => names.remove(x["name"]));
  print(result.length);
}

bool areMapsEqual(Map map1, Map map2) {
  if (map1.length != map2.length) return false;
  for (var key in map1.keys) {
    if (map1[key] != map2[key]) return false;
  }
  return true;
}
