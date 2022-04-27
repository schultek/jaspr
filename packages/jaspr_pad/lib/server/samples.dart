import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:path/path.dart' as path;

import '../main.mapper.g.dart';
import '../models/project.dart';
import '../models/sample.dart';
import '../providers/utils.dart';
import 'project.dart';

final sampleHeader = RegExp(r'//\s?\[sample(?:=(\d+))?\](\[hidden\])?(?:\s*)(.*)');

class SampleConfig {
  String description;
  int? index;
  bool hidden;
  String source;

  SampleConfig(this.description, this.index, this.hidden, this.source);

  static SampleConfig? from(String source) {
    var splitIndex = source.indexOf('\n');
    var line0 = source.substring(0, splitIndex == -1 ? null : splitIndex);

    if (sampleHeader.hasMatch(line0)) {
      var match = sampleHeader.firstMatch(line0)!;
      return SampleConfig(
        match.group(3)!.trim(),
        int.tryParse(match.group(1) ?? ''),
        match.group(2) != null,
        source.substring(splitIndex + 1),
      );
    }
    return null;
  }
}

Future<Response> getSample(Request request, String id) async {
  var description = id;
  String? html, css, dart;
  Map<String, String> dartFiles = {};

  var dir = Directory(path.join(samplesPath, id));

  SampleResponse result;

  if (!(await dir.exists())) {
    result = SampleResponse(null, 'Sample with id $id does not exist');
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
      } else if (name == 'workshop.yaml') {

      } else {
        print('[WARNING] Unsupported file $name in sample $id');
      }
    }));

    if (dart == null) {
      result = SampleResponse(null, 'Missing main.dart in sample $id');
    } else if (html == null) {
      result = SampleResponse(null, 'Missing index.html in sample $id');
    } else if (css == null) {
      result = SampleResponse(null, 'Missing styles.css in sample $id');
    } else {
      result = SampleResponse(
        ProjectData(
          id: id,
          description: description,
          htmlFile: html!,
          cssFile: css!,
          mainDartFile: dart!,
          dartFiles: dartFiles,
        ),
        null,
      );
    }
  }

  return Response.ok(Mapper.toJson(result), headers: {'Content-Type': 'application/json'});
}

final loadSamplesProvider = Provider<List<Sample>>((ref) {
  var samples = <Sample>[];

  ref.onPreload(() async {
    var dirs = await Directory(samplesPath).list().toList();

    var loadedSamples = (await Future.wait(dirs.map((dir) async {
      var id = path.basename(dir.path);
      var description = id;
      int? index;
      var mainFile = File(path.join(dir.path, 'main.dart'));

      if (await mainFile.exists()) {
        var config = SampleConfig.from(await mainFile.readAsString());
        if (config != null) {
          if (config.hidden) {
            return null;
          }
          description = config.description;
          index = config.index;
        }
      }

      return Sample(id, description, index);
    })))
        .whereType<Sample>()
        .toList();

    loadedSamples.sort();
    samples.addAll(loadedSamples);
  });

  ref.onSync<List<Sample>>(
    id: 'samples',
    onUpdate: (_) {},
    onSave: () => samples,
    codec: MapperCodec(),
  );

  return samples;
});
