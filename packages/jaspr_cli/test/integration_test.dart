// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'configs.dart';
import 'utils.dart';

void main() {
  group('cli integration', () {
    var dirs = setupTempDirs();

    for (var config in configs) {
      test(config.name, () async {
        await run('jaspr create -v -t ${config.name} myapp --no-jaspr-web-compilers', dir: dirs.root());

        for (var file in config.files) {
          expect(File(p.join(dirs.app().path, file)).existsSync(), isTrue);
        }

        // Override jaspr dependencies from path.
        await bootstrap(config.name, dirs.root());

        await run('jaspr clean --kill', dir: dirs.app());
        var stop = await start('jaspr serve -v', dir: dirs.app());

        // Wait until server is started.
        while (true) {
          try {
            await http.get(Uri.parse('http://localhost:8080'));
            break;
          } on SocketException catch (_) {}
          await Future.delayed(Duration(seconds: 5));
        }

        var paths = config.resources;
        for (var path in paths) {
          await expectLater(
            http.get(Uri.parse(p.url.join('http://localhost:8080', path))).then((r) {
              print("Fetched '$path' -> ${r.statusCode}");

              return r;
            }),
            completion(predicate((http.Response r) => r.statusCode == 200)),
          );
        }

        await stop();

        await run('jaspr clean --kill', dir: dirs.app());
        await run('jaspr build -v', dir: dirs.app());

        for (var file in config.outputs) {
          expect(File(p.join(dirs.app().path, 'build', 'jaspr', file)).existsSync(), isTrue);
        }
      }, timeout: Timeout(Duration(minutes: 2)));
    }
  });
}

Future<void> bootstrap(String name, Directory dir) async {
  var jasprDir = Process.runSync('git', ['rev-parse', '--show-toplevel'], runInShell: true).stdout.trim();

  var overrides = File(p.join(dir.path, 'myapp', 'pubspec_overrides.yaml'));
  overrides.createSync();
  overrides.writeAsString(jsonEncode({
    'dependency_overrides': {
      'jaspr': {"path": p.join(jasprDir, 'packages', 'jaspr')},
      'jaspr_builder': {"path": p.join(jasprDir, 'packages', 'jaspr_builder')},
    }
  }));

  await run('dart pub get', dir: Directory(p.join(dir.path, 'myapp')));
}
