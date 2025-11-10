// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:jaspr_cli/src/command_runner.dart';
import 'package:jaspr_cli/src/commands/base_command.dart';
import 'package:jaspr_cli/src/commands/create_command.dart';
import 'package:jaspr_cli/src/commands/serve_command.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'utils.dart';
import 'variants.dart';

void main() {
  group('commands', () {
    var dirs = setupTempDirs();
    var runner = setupRunner();

    for (var variant in allVariants) {
      test(variant.name, tags: ['cli', variant.tag], () async {
        await runner.run('create --no-pub-get -v ${variant.options} myapp', dir: dirs.root);

        for (var f in variant.files) {
          expect(File(p.join(dirs.app().path, f.$1)), f.$2, reason: f.$1);
        }

        // Override jaspr dependencies from path.
        await bootstrap(variant, dirs.root());

        var serveResult = runner.run('serve -v', dir: dirs.app, checkExitCode: false);

        // Wait until server is started.
        await Future<void>.delayed(Duration(seconds: 10));
        while (true) {
          try {
            await http.head(Uri.parse('http://localhost:8080'));
            break;
          } on SocketException catch (_) {}
          await Future<void>.delayed(Duration(seconds: 5));
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

        // Wait for the server to be stopped.
        await runner.runner.commands.values.whereType<ServeCommand>().firstOrNull?.stop();
        await serveResult;
        await Future<void>.delayed(Duration(seconds: 5));

        await runner.run('build -v', dir: dirs.app);

        var outputPath = p.join(dirs.app().path, 'build', 'jaspr');
        if (variant.mode == RenderingMode.server) {
          outputPath = p.join(outputPath, 'web');
        }

        for (var f in variant.outputs) {
          expect(File(p.join(outputPath, f.$1)), f.$2, reason: f.$1);
        }
      });
    }
  });
}

Future<void> bootstrap(TestVariant variant, Directory dir) async {
  var jasprDir = (Process.runSync('git', ['rev-parse', '--show-toplevel'], runInShell: true).stdout as String).trim();

  var overrides = File(p.join(dir.path, 'myapp', 'pubspec_overrides.yaml'));
  overrides.createSync();
  overrides.writeAsString(
    jsonEncode({
      'dependency_overrides': {
        'jaspr': {"path": p.join(jasprDir, 'packages', 'jaspr')},
        'jaspr_builder': {"path": p.join(jasprDir, 'packages', 'jaspr_builder')},
        'jaspr_lints': {"path": p.join(jasprDir, 'packages', 'jaspr_lints')},
        for (var package in variant.packages) p.basename(package): {"path": p.join(jasprDir, package)},
      },
    }),
  );

  await run('dart pub get', dir: Directory(p.join(dir.path, 'myapp')));
}

TestRunner setupRunner() {
  TestRunner runner = TestRunner();

  setUp(() {
    runner.setup();
  });

  tearDown(() async {
    await Future.wait(runner.runner.commands.values.whereType<BaseCommand>().map((c) => c.stop()));
  });

  return runner;
}

class TestRunner {
  late JasprCommandRunner runner;

  Future<int?> run(String command, {Directory Function()? dir, bool checkExitCode = true}) async {
    return await IOOverrides.runZoned(
      getCurrentDirectory: dir,
      () async {
        var res = await runner.run(command.split(' '));
        if (checkExitCode) {
          expect(res, equals(0));
        }
        return res;
      },
    );
  }

  void setup() {
    runner = JasprCommandRunner();
  }
}
