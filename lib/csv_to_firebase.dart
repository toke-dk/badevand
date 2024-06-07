import 'package:badevand/extenstions/string_extension.dart';
import 'package:badevand/main.dart';
import 'package:badevand/models/beach.dart';
import 'package:csv/csv.dart';
import 'package:coordinate_converter/coordinate_converter.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // new

Future<List<Beach>> getBeachesFromCSV(String path) async {
  List<List<dynamic>> rowsAsListOfValues =
      CsvToListConverter(fieldDelimiter: ";").convert(await _loadCSV(path));
  List<Map<String, dynamic>> result = rowsAsListOfValues.skip(1).map((row) {
    String name = row[2].toString();
    String municipality = row[13].toString();
    String id = row[1].toString();

    int zone = int.parse(row[4].toString());
    double xCords = row[5].toString().commaDecimalToDouble;
    double yCords = row[6].toString().commaDecimalToDouble;

    UTMCoordinates utmCords =
        UTMCoordinates(x: xCords, y: yCords, zoneNumber: zone);

    DDCoordinates ddCords = utmCords.toDD();

    double lat = ddCords.latitude;
    double lon = ddCords.longitude;

    return {
      "id": id,
      "name": name,
      "lat": lat,
      "lon": lon,
      "municipality": municipality
    };
  }).toList();
  // result.map((beach) async {
  //   print(beach["id"]);
  //
  // });

  final Set ids = result.map((e) => "${e['lat']}, ${e['lon']}").toSet();
  result.retainWhere((x) => ids.remove("${x['lat']}, ${x['lon']}"));

  //print(result[3]..remove("id"));

  // for (var beach in result) {
  //   print("name ${beach["name"]}");
  //   await FirebaseFirestore.instance
  //       .collection("beaches")
  //       .doc(beach["id"])
  //       .set(beach..remove("id"));
  // }
  print(result.length);

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return result
      .map((e) => Beach(
      id: e["id"],
      name: e["name"],
      position: LatLng(e["lat"], e["lon"]),
      isFavourite: getIsFavourite(prefs, e["id"]),
      municipality: e["municipality"]), )
      .toList();
}

bool areMapsEqual(Map map1, Map map2) {
  if (map1.length != map2.length) return false;
  for (var key in map1.keys) {
    if (map1[key] != map2[key]) return false;
  }
  return true;
}

Future<String> _loadCSV(String path) async {
  return rootBundle.loadString(path);
}
