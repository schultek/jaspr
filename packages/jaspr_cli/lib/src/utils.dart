import 'dart:io';

/// Gets the base url for pub mirror with respect to the value of `PUB_HOSTED_URL` enviroment variable.
///
/// Falls back to https://pub.dev if the enviroment variable is not found.
String getPubDevBaseUrl() {
  final mirror = Platform.environment['PUB_HOSTED_URL'];
  return mirror ?? 'https://pub.dev';
}
