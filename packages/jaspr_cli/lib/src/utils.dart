import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'dev/util.dart';
import 'logging.dart';

/// Gets the base url for pub mirror with respect to the value of `PUB_HOSTED_URL` enviroment variable.
///
/// Falls back to https://pub.dev if the enviroment variable is not found.
String getPubDevBaseUrl() {
  final mirror = Platform.environment['PUB_HOSTED_URL'];
  return mirror ?? 'https://pub.dev';
}

String? getJasprPackagePath({Logger? logger}) {
  final packageConfigPath = findPackageConfigFilePath();
  if (packageConfigPath == null) {
    logger?.write(
      'Could not find package_config.json. Make sure to run "dart pub get" first.',
      level: Level.error,
    );
    return null;
  }

  final packageConfigFile = File(packageConfigPath);
  final config = jsonDecode(packageConfigFile.readAsStringSync());
  String? jasprPackageUri;
  if (config case {'packages': final List<Object?> configPackages}) {
    final jasprEntry = configPackages.whereType<Map<String, dynamic>>().where((p) => p['name'] == 'jaspr').firstOrNull;
    if (jasprEntry != null) {
      jasprPackageUri = jasprEntry['rootUri'] as String?;
    }
  }

  if (jasprPackageUri == null) {
    logger?.write('Could not find "jaspr" package in package_config.json.', level: Level.error);
    return null;
  }

  final jasprPath = p.isAbsolute(jasprPackageUri) || jasprPackageUri.startsWith('file://')
      ? p.fromUri(jasprPackageUri)
      : p.normalize(p.join(p.dirname(packageConfigFile.absolute.path), jasprPackageUri));

  return jasprPath;
}
