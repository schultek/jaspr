import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:path/path.dart' as path;

import '../main.mapper.g.dart';
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
  SampleResponse result;

  try {
    result = SampleResponse(await loadProjectFromDirectory(id, path.join(samplesPath, id)), null);
  } on DirectoryNotFoundException {
    result = SampleResponse(null, 'Sample with id $id does not exist');
  } on MainDartFileMissingException {
    result = SampleResponse(null, 'Missing main.dart in sample $id');
  }

  return Response.ok(Mapper.toJson(result), headers: {'Content-Type': 'application/json'});
}

final loadSamplesProvider = SyncProvider<List<Sample>>((ref) async {
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
    } else {
      return null;
    }

    return Sample(id, description, index);
  })))
      .whereType<Sample>()
      .toList();

  loadedSamples.sort();

  return loadedSamples;
}, id: 'samples', codec: MapperCodec());
