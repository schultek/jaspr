import 'dart:io';

import 'package:jaspr_cli/src/commands/create_command.dart';
import 'package:jaspr_cli/src/commands/serve_command.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../src/fakes/fake_io.dart';
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

      await runner.run('create --no-pub-get --no-skills -v ${variant.options} myapp', dir: dirs.root);

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

      final output = FakeIOSink();
      final serveResult = IOOverrides.runZoned(
        () => runner.run('serve --auto=reload -v', dir: dirs.app, checkExitCode: false),
        stdin: FakeStdin.new,
        stdout: () => FakeStdout(output.sink),
      ).whenComplete(output.sink.close);
      addTearDown(() async {
        await output.queue.cancel(immediate: true);
        await runner.runner.commands.values.whereType<ServeCommand>().single.stop();
        expect(await serveResult, 0);
      });

      final cssFile = File(p.join(appDir.path, '.dart_tool', 'jaspr', 'generated', 'main.css'));
      await expectLater(
        output.queue,
        emitsWithTimeout(emitsThrough(contains('Generated main.css')), timeout: Duration(minutes: 3)),
      );
      expect(cssFile.readAsStringSync(), contains('.test-class {\n  color: red;\n}'));

      // The server only starts after the initial CSS generation completes,
      // so once it's listening, startup has settled and the next change
      // to the styles file triggers a regular rebuild and CSS reload.
      await expectLater(
        output.queue,
        emitsWithTimeout(emitsThrough(contains('Server started and listening on ')), timeout: Duration(minutes: 1)),
      );
      stylesContent = stylesContent.replaceAll('color: Colors.red', 'color: Colors.blue');
      stylesFile.writeAsStringSync(stylesContent);

      await expectLater(
        output.queue,
        emitsWithTimeout(emitsThrough(contains('Reloaded main.css')), timeout: Duration(seconds: 40)),
      );
      expect(cssFile.readAsStringSync(), contains('.test-class {\n  color: blue;\n}'));
    }, timeout: Timeout(Duration(minutes: 5)));
  });
}
