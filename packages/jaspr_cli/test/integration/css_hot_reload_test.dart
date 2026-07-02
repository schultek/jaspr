// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:jaspr_cli/src/commands/create_command.dart';
import 'package:jaspr_cli/src/commands/serve_command.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'commands_integration_test.dart';
import 'utils.dart';
import 'variants.dart';

void main() {
  group('css hot reload', () {
    final dirs = setupTempDirs();
    final runner = setupRunner();

    test('hot reloads css with js_interop', () async {
      final variant = const TestVariant(
        mode: RenderingMode.server,
        routing: RoutingOption.none,
        flutter: FlutterOption.none,
        backend: BackendOption.none,
      );

      await runner.run('create --no-pub-get -v ${variant.options} myapp', dir: dirs.root);

      await bootstrap(
        variant,
        dirs.root(),
        standaloneStyles: true,
        packageOverrides: {
          'universal_web': {
            'git': {
              'url': 'https://github.com/schultek/universal_web',
              'path': 'web',
              'ref': 'next',
            },
          },
          'web': {
            'git': {
              'url': 'https://github.com/dart-lang/web',
              'path': 'web',
              'ref': '48b75126e511e2d3de65130f2e7aa21cca58f473',
            },
          },
        },
      );

      final appDir = dirs.app();

      // Inject css and js_interop
      final stylesFile = File(p.join(appDir.path, 'lib', 'test_styles.dart'));

      var stylesContent = """
import 'dart:js_interop';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

@css
final styles = [
  css('.test-class').styles(color: Colors.red),
];
""";
      stylesFile.writeAsStringSync(stylesContent);

      final serveResult = runner.run('serve -v', dir: dirs.app, checkExitCode: false);

      // Wait until server is started.
      await Future<void>.delayed(Duration(seconds: 10));
      while (true) {
        try {
          await http.head(Uri.parse('http://localhost:8080'));
          break;
        } on SocketException catch (_) {}
        await Future<void>.delayed(Duration(seconds: 5));
      }

      // Wait a little extra to ensure initial CSS is completely built
      await Future<void>.delayed(Duration(seconds: 2));

      // Check initial CSS
      final cssFile = File(p.join(appDir.path, '.dart_tool', 'jaspr', 'generated', 'main.css'));
      expect(cssFile.existsSync(), isTrue);
      expect(cssFile.readAsStringSync(), contains('.test-class {\n  color: red;\n}'));

      // Mutate CSS
      stylesContent = stylesContent.replaceAll('color: Colors.red', 'color: Colors.blue');
      stylesFile.writeAsStringSync(stylesContent);

      // Wait for hot reload and poll
      bool updated = false;
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(Duration(seconds: 2));
        if (cssFile.readAsStringSync().contains('.test-class {\n  color: blue;\n}')) {
          updated = true;
          break;
        }
      }

      expect(updated, isTrue, reason: 'CSS was not updated within 40 seconds');

      // Wait for the server to be stopped.
      await runner.runner.commands.values.whereType<ServeCommand>().firstOrNull?.stop();
      await serveResult;
    }, timeout: Timeout(Duration(minutes: 3)));
  });
}
