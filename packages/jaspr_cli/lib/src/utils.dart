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

(String?, Map<String, Object?>?) getPackagesFile({Logger? logger}) {
  final packageConfigPath = findPackageConfigFilePath();
  if (packageConfigPath == null) {
    logger?.write(
      'Could not find package_config.json. Make sure to run "dart pub get" first.',
      level: Level.error,
    );
    return (null, null);
  }

  final packageConfigFile = File(packageConfigPath);
  final config = jsonDecode(packageConfigFile.readAsStringSync());

  return (packageConfigPath, config as Map<String, Object?>);
}

String? getJasprPackagePath(String packageConfigPath, Map<String, Object?> packageConfig, {Logger? logger}) {
  String? jasprPackageUri;
  if (packageConfig case {'packages': final List<Object?> configPackages}) {
    final jasprEntry = configPackages.whereType<Map<String, dynamic>>().where((p) => p['name'] == 'jaspr').firstOrNull;
    if (jasprEntry != null) {
      jasprPackageUri = jasprEntry['rootUri'] as String?;
    }
  }

  if (jasprPackageUri == null) {
    logger?.write(
      'Could not find "jaspr" package in package_config.json. Make sure you are in a package or workspace using Jaspr.',
      level: Level.error,
    );
    return null;
  }

  final jasprPath = p.isAbsolute(jasprPackageUri) || jasprPackageUri.startsWith('file://')
      ? p.fromUri(jasprPackageUri)
      : p.normalize(p.join(p.dirname(p.absolute(packageConfigPath)), jasprPackageUri));

  return jasprPath;
}
