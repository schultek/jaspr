import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> copyFiles(String from, String to, [List<String> targets = const ['']]) async {
  var moveTargets = [...targets];

  var moves = <Future>[];
  while (moveTargets.isNotEmpty) {
    var moveTarget = moveTargets.removeAt(0);
    var file = File('$from/$moveTarget');
    var isDir = file.statSync().type == FileSystemEntityType.directory;
    if (isDir) {
      await Directory('$to/$moveTarget').create(recursive: true);

      var files = Directory('$from/$moveTarget').list(recursive: true);
      await for (var file in files) {
        final path = p.relative(file.path, from: from);
        if (file is Directory) {
          moveTargets.add(path);
        } else {
          moveTargets.add(path);
        }
      }
    } else {
      moves.add(file.copy('./$to/$moveTarget'));
    }
  }

  await Future.wait(moves);
}
