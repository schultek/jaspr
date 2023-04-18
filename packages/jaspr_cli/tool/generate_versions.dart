import 'dart:convert';
import 'dart:io';

void main() async {
  var output = StringBuffer('// ignore_for_file: directives_ordering\n'
      '// GENERATED FILE - DO NOT MODIFY\n\n');

  var packages = await Process.run('melos', 'list --no-private --json'.split(' '), stdoutEncoding: utf8);
  var packagesJson = jsonDecode(packages.stdout) as List;

  var jasprCliVersion = packagesJson.firstWhere((p) => p['name'] == 'jaspr_cli')['version'];
  var jasprVersion = packagesJson.firstWhere((p) => p['name'] == 'jaspr')['version'];
  var jasprBuilderVersion = packagesJson.firstWhere((p) => p['name'] == 'jaspr_builder')['version'];

  output.writeln('const jasprCliVersion = "$jasprCliVersion";\n'
      'const jasprCoreVersion = "$jasprVersion";\n'
      'const jasprBuilderVersion = "$jasprBuilderVersion";');

  var versionsFile = File('lib/src/version.dart');
  await versionsFile.writeAsString(output.toString());
}

String toCamelCase(String s) {
  var c = s.split('_');
  return [c.first, ...c.skip(1).map((c) => c[0].toUpperCase() + c.substring(1))].join();
}
