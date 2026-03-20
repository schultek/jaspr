import 'dart:convert';
import 'dart:io';

import 'package:pub_semver/pub_semver.dart';

void main() async {
  final output = StringBuffer(
    '// ignore_for_file: directives_ordering\n'
    '// GENERATED FILE - DO NOT MODIFY\n\n',
  );

  final packages = await Process.run('melos', 'list --no-private --json'.split(' '), stdoutEncoding: utf8);
  final jsonStartIndex = (packages.stdout as String).indexOf('[');
  final packagesJson = (jsonDecode((packages.stdout as String).substring(jsonStartIndex)) as List<Object?>)
      .cast<Map<String, Object?>>();

  final jasprCliVersion = packagesJson.firstWhere((p) => p['name'] == 'jaspr_cli')['version'] as String;
  final jasprVersion = packagesJson.firstWhere((p) => p['name'] == 'jaspr')['version'] as String;
  final jasprBuilderVersion = packagesJson.firstWhere((p) => p['name'] == 'jaspr_builder')['version'] as String;

  output.writeln(
    'const jasprCliVersion = \'$jasprCliVersion\';\n'
    'const jasprCoreVersion = \'$jasprVersion\';\n'
    'const jasprBuilderVersion = \'$jasprBuilderVersion\';',
  );

  final versionsFile = File('lib/src/version.dart');
  await versionsFile.writeAsString(output.toString());

  final parsedJasprVersion = Version.parse(jasprVersion);
  final majorJasprVersion = Version(parsedJasprVersion.major, parsedJasprVersion.minor, 0).toString();

  final skillsFiles = Directory('../jaspr/skills').listSync(recursive: true);
  for (final file in skillsFiles) {
    if (file is File && file.path.endsWith('SKILL.md')) {
      final content = file.readAsStringSync();
      final metadataMatch = RegExp(r'^---(.*?)---', dotAll: true).firstMatch(content);
      if (metadataMatch != null) {
        final metadata = metadataMatch.group(1)!;
        final versionMatch = RegExp(r'minimum_jaspr_version: (.*)').firstMatch(metadata);
        if (versionMatch != null) {
          final output = content.replaceFirst(versionMatch.group(0)!, 'minimum_jaspr_version: $majorJasprVersion');
          file.writeAsStringSync(output);
        }
      }
    }
  }
}
