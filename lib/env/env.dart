// lib/env/env.dart
import 'package:envied/envied.dart';
part 'env.g.dart';

//This file contains the keys for our API's

@Envied(path: ".env")
abstract class Env {
  @EnviedField(varName: 'METEO_USERNAME') // the .env variable.
  static const String meteoUsername = _Env.meteoUsername;
  @EnviedField(varName: 'METEO_PASSWORD')
  static const String meteoPassword = _Env.meteoPassword;
}