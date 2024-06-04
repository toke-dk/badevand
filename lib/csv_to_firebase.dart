import 'dart:io';
import 'package:badevand/extenstions/string_extension.dart';
import 'package:badevand/firebase_options.dart';
import 'package:csv/csv.dart';
import 'package:coordinate_converter/coordinate_converter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart'; // new

Future<void> setDataFromCSV(String path) async {
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
