import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:io/ansi.dart';

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

/// Returns the visual length of the string, excluding ANSI escape sequences.
int visualLength(String text) {
  return text.replaceAll(RegExp(r'(\x1B|\\033)\[[0-9;]*[a-zA-Z]', caseSensitive: false), '').length;
}

String wrapText(String text, int maxWidth, {int prefixLength = 0}) {
  final lines = text.split('\n');

  final wrappedLines = <String>[];

  for (final line in lines) {
    if (line.trim().isEmpty) {
      wrappedLines.add(line);
      continue;
    }

    final leadingSpacesCount = line.length - line.trimLeft().length;
    var currentLine = ' ' * leadingSpacesCount;
    var currentVisualLength = leadingSpacesCount;

    final words = line.trimLeft().split(' ');
    var isFirstWord = true;

    for (final word in words) {
      final wordVisualLength = visualLength(word);
      if (isFirstWord) {
        currentLine += word;
        currentVisualLength += wordVisualLength;
        isFirstWord = false;
      } else {
        const spaceLength = 1;
        if (currentVisualLength + spaceLength + wordVisualLength <= maxWidth) {
          currentLine += ' $word';
          currentVisualLength += spaceLength + wordVisualLength;
        } else {
          wrappedLines.add(currentLine);
          currentLine = (' ' * prefixLength) + word;
          currentVisualLength = prefixLength + wordVisualLength;
        }
      }
    }
    if (currentLine.isNotEmpty) {
      wrappedLines.add(currentLine);
    }
  }
  return wrappedLines.join('\n');
}

String wrapBox(String message, {bool centerLines = false, AnsiCode? borderColor}) {
  final columns = stdout.hasTerminal ? stdout.terminalColumns : 80;
  final maxInnerWidth = max(20, columns - 6);

  final wrappedMessage = wrapText(message, maxInnerWidth);
  final wrappedLines = wrappedMessage.split('\n');

  final lengths = wrappedLines.map(visualLength).toList();
  final maxLength = lengths.isEmpty ? 0 : lengths.reduce(max);

  final buffer = StringBuffer();
  final borderTop = '┌${'─' * (maxLength + 4)}┐';
  final borderBottom = '└${'─' * (maxLength + 4)}┘';

  final borderTopStr = borderColor?.wrap(borderTop) ?? borderTop;
  final borderBottomStr = borderColor?.wrap(borderBottom) ?? borderBottom;
  final verticalBorderStr = borderColor?.wrap('│') ?? '│';

  buffer.writeln(borderTopStr);
  for (final (i, l) in wrappedLines.indexed) {
    if (centerLines) {
      final pad = (maxLength - lengths[i]) / 2;
      final padL = ''.padLeft(pad.floor());
      final padR = ''.padLeft(pad.ceil());
      buffer.writeln('$verticalBorderStr  $padL$l$padR  $verticalBorderStr');
    } else {
      final spaces = ' ' * (maxLength - lengths[i]);
      buffer.writeln('$verticalBorderStr  $l$spaces  $verticalBorderStr');
    }
  }
  buffer.write(borderBottomStr);
  return buffer.toString();
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
