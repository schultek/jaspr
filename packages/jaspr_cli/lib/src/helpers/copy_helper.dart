import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> copyFiles(String from, String to, [List<String> targets = const ['']]) async {
  var moveTargets = [...targets];

  var moves = <Future>[];
  while (moveTargets.isNotEmpty) {
    var moveTarget = moveTargets.removeAt(0);
    var file = File('$from/$moveTarget').absolute;
    var isDir = file.statSync().type == FileSystemEntityType.directory;
    if (isDir) {
      await Directory('$to/$moveTarget').absolute.create(recursive: true);

      var files = Directory('$from/$moveTarget').absolute.list(recursive: true);
      await for (var file in files) {
        final path = p.relative(file.absolute.path, from: p.join(Directory.current.path, from));
        moveTargets.add(path);
      }
    } else {
      moves.add(file.copy('./$to/$moveTarget'));
    }
  }

  await Future.wait(moves);
}
