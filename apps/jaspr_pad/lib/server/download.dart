import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:jaspr/server.dart';
import 'package:path/path.dart' as path;

import '../models/project.dart';
import 'project.dart';

Future<Response> downloadProject(Request request) async {
  var param = request.url.queryParameters['project']!;
  var data = jsonDecode(utf8.decode(base64Decode(param)));
  var project = ProjectDataMapper.fromMap(data);

  var encoder = ZipProjectEncoder();
  await encoder.zipProject(project);

  return Response.ok(encoder._output.getBytes());
}

class ZipProjectEncoder {
  final OutputMemoryStream _output = OutputMemoryStream();
  final ZipEncoder _encoder = ZipEncoder();

  Future<void> zipProject(ProjectData project) async {
    _encoder.startEncode(_output);

    var replacements = {
      'project_name': project.id?.replaceAll('-', '_') ?? 'jaspr_app',
      'project_description': project.description ?? 'Simple jaspr project',
      'project_title': project.description ?? 'Jaspr',
      'project_html': project.htmlFile?.indent('    ') ?? '',
    };

    await addFromFile('pubspec.yaml', replacements);
    await addFromFile('analysis_options.yaml', replacements);
    await addFromFile('web/main.dart', replacements);
    await addFromFile('web/index.html', replacements);

    addFromSource('web/styles.css', project.cssFile ?? '');
    addFromSource('lib/main.dart', project.mainDartFile);

    for (var file in project.dartFiles.keys) {
      addFromSource('lib/$file', project.dartFiles[file]!);
    }

    close();
  }

  Future<void> addFromFile(String name, Map<String, String> replacements) async {
    var file = File(path.join(jasprExportTemplatePath, name));
    var source = await file.readAsString();

    for (var key in replacements.keys) {
      source = source.replaceAll('{{$key}}', replacements[key]!);
    }

    addFromSource(name, source);
  }

  void addFromSource(String file, String source) {
    _encoder.add(ArchiveFile.string(file, source));
  }

  void close() {
    _encoder.endEncode();
    _output.flush();
  }
}

extension Indent on String {
  String indent(String pad) {
    return split('\n').map((s) => pad + s).join('\n');
  }
}
