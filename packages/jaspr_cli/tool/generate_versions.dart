import 'dart:convert';
import 'dart:io';

void main() async {
  final output = StringBuffer(
    '// ignore_for_file: directives_ordering\n'
    '// GENERATED FILE - DO NOT MODIFY\n\n',
  );

  final packages = await Process.run('melos', 'list --no-private --json'.split(' '), stdoutEncoding: utf8);
  final jsonStartIndex = (packages.stdout as String).indexOf('[');
  final packagesJson = (jsonDecode((packages.stdout as String).substring(jsonStartIndex)) as List<Object?>)
      .cast<Map<String, Object?>>();

  final jasprCliVersion = packagesJson.firstWhere((p) => p['name'] == 'jaspr_cli')['version'];
  final jasprVersion = packagesJson.firstWhere((p) => p['name'] == 'jaspr')['version'];
  final jasprBuilderVersion = packagesJson.firstWhere((p) => p['name'] == 'jaspr_builder')['version'];

  output.writeln(
    'const jasprCliVersion = \'$jasprCliVersion\';\n'
    'const jasprCoreVersion = \'$jasprVersion\';\n'
    'const jasprBuilderVersion = \'$jasprBuilderVersion\';',
  );

  final versionsFile = File('lib/src/version.dart');
  await versionsFile.writeAsString(output.toString());
}
