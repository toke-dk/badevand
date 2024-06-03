
import 'dart:io';

import 'package:csv/csv.dart';

Future<void> main(List<String> arguments) async {

    final path = arguments[0];
    final file = File(path);
    List<List<dynamic>> rowsAsListOfValues = CsvToListConverter(fieldDelimiter: ";").convert(await file.readAsString());
    print(rowsAsListOfValues[1]);
}