import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../models/api_models.dart';
import 'project.dart';

class Compiler {
  Future<CompileResponse> compile(CompileRequest request) async {
    final temp = await Directory.systemTemp.createTemp('dartpad');

    try {
      var fromPath = path.join(projectTemplatePath, 'jaspr_basic');
      await copyPath(fromPath, temp.path);
      await fixPathPackages(fromPath, temp.path);

      await Directory(path.join(temp.path, 'lib')).create(recursive: true);

      for (var key in request.sources.keys) {
        final file = File(path.join(temp.path, 'lib', key));
        await file.writeAsString(request.sources[key]!);
      }

      final arguments = <String>[
        'compile',
        'js',
        '--suppress-hints',
        '--terse',
        '--packages=${path.join('.dart_tool', 'package_config.json')}',
        '--sound-null-safety',
        '--enable-asserts',
        '-o',
        'main.js',
        'web/main.dart',
      ];

      final result = await Process.run('dart', arguments, workingDirectory: temp.path);

      if (result.exitCode != 0) {
        return CompileResponse(null, result.stdout as String);
      } else {
        final mainJs = File(path.join(temp.path, 'main.js'));
        return CompileResponse(await mainJs.readAsString(), null);
      }
    } catch (e, st) {
      print('Compiler failed: $e\n$st');
      rethrow;
    } finally {
      await temp.delete(recursive: true);
    }
  }
}

/// Copies all of the files in the [from] directory to [to].
///
/// This is similar to `cp -R <from> <to>`:
/// * Symlinks are supported.
/// * Existing files are over-written, if any.
/// * If [to] is within [from], throws [ArgumentError] (an infinite operation).
/// * If [from] and [to] are canonically the same, no operation occurs.
///
/// Returns a future that completes when complete.
Future<void> copyPath(String from, String to) async {
  if (_doNothing(from, to)) {
    return;
  }
  await Directory(to).create(recursive: true);
  await for (final file in Directory(from).list(recursive: true)) {
    final copyTo = path.join(to, path.relative(file.path, from: from));
    if (file is Directory) {
      await Directory(copyTo).create(recursive: true);
    } else if (file is File) {
      await File(file.path).copy(copyTo);
    } else if (file is Link) {
      await Link(copyTo).create(await file.target(), recursive: true);
    }
  }
}

bool _doNothing(String from, String to) {
  if (path.canonicalize(from) == path.canonicalize(to)) {
    return true;
  }
  if (path.isWithin(from, to)) {
    throw ArgumentError('Cannot copy from $from to $to');
  }
  return false;
}

Future<void> fixPathPackages(String from, String to) async {
  var packagesFile = File(path.join(to, '.dart_tool', 'package_config.json'));
  var packageJson = jsonDecode(await packagesFile.readAsString());
  bool hasChanged = false;
  for (var package in packageJson['packages']) {
    if (package['name'] == 'jaspr_basic_template') continue;
    var uri = package['rootUri'];
    if (!uri.startsWith('file://') && path.isRelative(uri)) {
      package['rootUri'] = 'file://' + path.normalize(path.join(from, '.dart_tool', uri));
      hasChanged = true;
    }
  }
  if (hasChanged) {
    await packagesFile.writeAsString(jsonEncode(packageJson));
  }
}
