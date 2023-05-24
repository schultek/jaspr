import 'dart:io';

import 'package:path/path.dart' as path;

void main() async {
  var templatesDir = Directory('tool/templates');

  var subDirs = await templatesDir.list().toList();
  var templates = <String>[];

  var output = StringBuffer('// ignore_for_file: directives_ordering\n'
      '// GENERATED FILE - DO NOT MODIFY\n\n');

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
    }
  }

  templates.sort();
  for (var t in templates) {
    output.writeln("import './templates/${t}_bundle.dart';");
  }
  output.writeln('\nvar templates = [${templates.map((t) => '${toCamelCase(t)}Bundle').join(', ')}];');

  var templatesFile = File('lib/src/templates.dart');
  await templatesFile.writeAsString(output.toString());
}

String toCamelCase(String s) {
  var c = s.split('_');
  return [c.first, ...c.skip(1).map((c) => c[0].toUpperCase() + c.substring(1))].join();
}
