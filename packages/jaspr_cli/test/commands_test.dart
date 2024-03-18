// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:jaspr_cli/src/command_runner.dart';
import 'package:jaspr_cli/src/commands/base_command.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'utils.dart';
import 'variants.dart';

void main() {
  group('commands', () {
    var dirs = setupTempDirs();
    var runner = setupRunner();

    for (var variant in variants) {
      test(variant.name, tags: variant.tag, () async {
        await runner.run('create -v ${variant.options} myapp', dir: dirs.root);

        for (var f in variant.files) {
          expect(File(p.join(dirs.app().path, f.$1)), f.$2, reason: f.$1);
        }

        // Override jaspr dependencies from path.
        await bootstrap(variant, dirs.root());

        runner.run('serve -v', dir: dirs.app);

        // Wait until server is started.
        while (true) {
          try {
            await http.get(Uri.parse('http://localhost:8080'));
            break;
          } on SocketException catch (_) {}
          await Future.delayed(Duration(seconds: 5));
        }

        var paths = variant.resources;
        for (var path in paths) {
          await expectLater(
            http.get(Uri.parse(p.url.join('http://localhost:8080', path))).then((r) {
              print("Fetched '$path' -> ${r.statusCode}");

              return r;
            }),
            completion(predicate((http.Response r) => r.statusCode == 200)),
          );
        }

        await runner.stop();

        await runner.run('build -v', dir: dirs.app);

        for (var file in variant.outputs) {
          expect(File(p.join(dirs.app().path, 'build', 'jaspr', file)).existsSync(), isTrue);
        }
      });
    }
  });
}

Future<void> bootstrap(TestVariant variant, Directory dir) async {
  var jasprDir = Process.runSync('git', ['rev-parse', '--show-toplevel'], runInShell: true).stdout.trim();

  var overrides = File(p.join(dir.path, 'myapp', 'pubspec_overrides.yaml'));
  overrides.createSync();
  overrides.writeAsString(jsonEncode({
    'dependency_overrides': {
      'jaspr': {"path": p.join(jasprDir, 'packages', 'jaspr')},
      'jaspr_builder': {"path": p.join(jasprDir, 'packages', 'jaspr_builder')},
      for (var package in variant.packages) p.basename(package): {"path": p.join(jasprDir, package)},
    }
  }));

  await run('dart pub get', dir: Directory(p.join(dir.path, 'myapp')));
}

TestRunner setupRunner() {
  TestRunner runner = TestRunner();

  setUp(() {
    runner.setup();
  });

  tearDown(() {
    runner.stop();
  });

  return runner;
}

class TestRunner {
  late JasprCommandRunner runner;

  Future<void> run(String command, {Directory Function()? dir}) async {
    await IOOverrides.runZoned(getCurrentDirectory: dir, () async {
      var res = await runner.run(command.split(' '));
      expect(res, equals(0));
    });
  }

  void setup() {
    runner = JasprCommandRunner();
  }

  Future<void> stop() async {
    await Future.wait(runner.commands.values.whereType<BaseCommand>().map((c) => c.stop()));
  }
}
