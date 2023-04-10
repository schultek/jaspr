import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

void main() async {
  var templatesDir = Directory('tool/templates');

  var subDirs = await templatesDir.list().toList();
  var templates = <String>[];

  var output = StringBuffer('// ignore_for_file: directives_ordering\n\n');

  for (var templateDir in subDirs) {
    if (templateDir is Directory) {
      var result = await Process.run('mason', 'bundle -t dart -o lib/src/templates ${templateDir.path}'.split(' '));
      stdout.write(result.stdout);
      stderr.write(result.stderr);

      if (result.exitCode != 0) {
        exit(result.exitCode);
      }

      var name = path.basenameWithoutExtension(templateDir.path);
      templates.add(name);
      output.writeln("import './templates/${name}_bundle.dart';");
    }
  }

  templates.sort();
  output.writeln('\nvar templates = [${templates.map((t) => '${toCamelCase(t)}Bundle').join(', ')}];');

  var packages = await Process.run('melos', 'list --no-private --json'.split(' '), stdoutEncoding: utf8);
  var packagesJson = jsonDecode(packages.stdout) as List;

  var jasprCliVersion = packagesJson.firstWhere((p) => p['name'] == 'jaspr_cli')['version'];
  var jasprVersion = packagesJson.firstWhere((p) => p['name'] == 'jaspr')['version'];
  var jasprBuilderVersion = packagesJson.firstWhere((p) => p['name'] == 'jaspr_builder')['version'];

  output.writeln('\nconst jasprCliVersion = "$jasprCliVersion";\n'
      'const jasprCoreVersion = "$jasprVersion";\n'
      'const jasprBuilderVersion = "$jasprBuilderVersion";');

  var templatesFile = File('lib/src/version.dart');
  await templatesFile.writeAsString(output.toString());
}

String toCamelCase(String s) {
  var c = s.split('_');
  return [c.first, ...c.skip(1).map((c) => c[0].toUpperCase() + c.substring(1))].join();
}
