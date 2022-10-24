import 'dart:io';

import 'package:path/path.dart' as path;

import '../models/project.dart';
import 'samples.dart';

String templatesPath = path.join(Directory.current.path, 'templates');

String jasprBasicTemplatePath = path.join(templatesPath, 'jaspr_basic');
String jasprExportTemplatePath = path.join(templatesPath, 'jaspr_export');

String samplesPath = path.join(Directory.current.path, 'samples');
String tutorialPath = path.join(Directory.current.path, 'samples', 'tutorial');

Future<ProjectData> loadProjectFromDirectory(String id, String dirPath) async {
  var description = id;
  String? html, css, dart;
  Map<String, String> dartFiles = {};

  var dir = Directory(dirPath);
  if (!(await dir.exists())) {
    throw DirectoryNotFoundException();
  } else {
    var files = await dir.list().toList();

    await Future.wait(files.map((file) async {
      if ((await file.stat()).type == FileSystemEntityType.directory) {
        return;
      }

      var name = path.basename(file.path);
      Future<String> read() => File(file.path).readAsString();

      if (name == 'main.dart') {
        dart = await read();
        var config = SampleConfig.from(dart!);
        if (config != null) {
          description = config.description;
          dart = config.source;
        }
      } else if (name == 'index.html') {
        html = await read();
      } else if (name == 'styles.css') {
        css = await read();
      } else if (name.endsWith('.dart')) {
        dartFiles[name] = await read();
      } else {
        print('[WARNING] Unsupported file $name in sample $id');
      }
    }));

    if (dart == null) {
      throw MainDartFileMissingException();
    } else {
      return ProjectData(
        id: 'sample-$id',
        description: description,
        htmlFile: html,
        cssFile: css,
        mainDartFile: dart!,
        dartFiles: dartFiles,
      );
    }
  }
}

class DirectoryNotFoundException implements Exception {}

class MainDartFileMissingException implements Exception {}
