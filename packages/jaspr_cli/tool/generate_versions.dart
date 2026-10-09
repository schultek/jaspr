import 'dart:convert';
import 'dart:io';

void main() async {
  final output = StringBuffer(
    '// ignore_for_file: directives_ordering\n'
    '// GENERATED FILE - DO NOT MODIFY\n\n',
  );

  final packages = await Process.run(
    Platform.resolvedExecutable,
    ['run', 'melos', 'list', '--no-private', '--json'],
    workingDirectory: '../..',
    stdoutEncoding: utf8,
  );
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
}
