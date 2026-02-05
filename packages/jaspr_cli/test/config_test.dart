import 'package:file/memory.dart';
import 'package:jaspr_cli/src/logging.dart';
import 'package:jaspr_cli/src/project.dart';
import 'package:test/test.dart';

class TestLogger extends Logger {
  TestLogger({super.verbose = false}) : super.base();

  final messages = <String>[];

  @override
  void complete(bool success) {}

  @override
  void writeLine(String message, {Tag? tag, Level level = Level.info, ProgressState? progress}) {
    messages.add(message);
  }
}

void main() {
  group('project', () {
    late MemoryFileSystem fs;
    late TestLogger logger;
    late List<int> exits;
    late Project project;

    setUp(() {
      fs = MemoryFileSystem();
      logger = TestLogger();
      exits = [];
      project = Project(
        logger,
        fs: fs,
        exitFn: (code) {
          exits.add(code);
          throw StateError('Exit called with code $code');
        },
      );
    });

    test('missing pubspec causes exit', () {
      expect(project.pubspecYaml, isNull);
      expect(() => project.requirePubspecYaml, throwsStateError);
      expect(
        logger.messages,
        contains('Could not find pubspec.yaml file. Make sure to run jaspr in your root project directory.'),
      );
      expect(exits, equals([1]));
    });

    group('jaspr config', () {
      test('with correct mode and port', () {
        fs.file('pubspec.yaml').writeAsStringSync('''
name: test
dependencies:
  jaspr: any
jaspr:
  mode: server
  port: 8080
  flutter: embedded
''');

        expect(project.pubspecYaml, isNotNull);
        expect(project.requirePubspecYaml, isNotNull);
        expect(() => project.requireJasprDependency, isNot(throwsException));
        expect(project.modeOrNull, equals(JasprMode.server));
        expect(project.requireMode, equals(JasprMode.server));
        expect(project.port, equals('8080'));
        expect(project.flutterMode, equals(FlutterMode.embedded));
        expect(logger.messages, isEmpty);
        expect(exits, isEmpty);
      });

      test('with invalid mode causes exit', () {
        fs.file('pubspec.yaml').writeAsStringSync('''
name: test
dependencies:
  jaspr: any
jaspr:
  mode: unknown
''');

        expect(project.modeOrNull, isNull);
        expect(() => project.requireMode, throwsStateError);
        expect(logger.messages, contains('\'jaspr.mode\' in pubspec.yaml must be one of static, server, client.'));
        expect(exits, equals([1]));
      });

      test('with invalid port causes exit', () {
        fs.file('pubspec.yaml').writeAsStringSync('''
name: test
dependencies:
  jaspr: any
jaspr:
  mode: client
  port: 'abc'
''');

        expect(() => project.port, throwsStateError);
        expect(logger.messages, contains('\'jaspr.port\' in pubspec.yaml must be an integer.'));
        expect(exits, equals([1]));
      });

      test('with invalid flutter mode causes exit', () {
        fs.file('pubspec.yaml').writeAsStringSync('''
name: test
dependencies:
  jaspr: any
jaspr:
  mode: client
  flutter: unknown
''');

        expect(() => project.flutterMode, throwsStateError);
        expect(logger.messages, contains('\'jaspr.flutter\' in pubspec.yaml must be one of embedded, plugins, none.'));
        expect(exits, equals([1]));
      });
    });

    group('dependencies', () {
      test('identifies existing dependencies', () {
        fs.file('pubspec.yaml').writeAsStringSync('''
name: test
dependencies:
  jaspr: any
  flutter:
    sdk: flutter
dev_dependencies:
  jaspr_builder: any
''');

        expect(() => project.requireJasprDependency, isNot(throwsException));
        expect(() => project.preferJasprBuilderDependency, isNot(throwsException));
        expect(project.flutterMode, FlutterMode.none);
        expect(logger.messages, isEmpty);
        expect(exits, isEmpty);
      });

      test('identifies missing dependencies', () {
        fs.file('pubspec.yaml').writeAsStringSync('''
name: test
''');

        expect(() => project.requireJasprDependency, throwsStateError);

        expect(
          logger.messages,
          contains('Missing dependency on jaspr in pubspec.yaml file. Make sure to add jaspr to your dependencies.'),
        );
        expect(() => project.preferJasprBuilderDependency, isNot(throwsException));
        expect(
          logger.messages,
          contains(
            'Missing dependency on jaspr_builder in pubspec.yaml file. Make sure to add jaspr_builder to your dev_dependencies.',
          ),
        );
        expect(project.flutterMode, FlutterMode.none);
        expect(logger.messages, hasLength(2));
        expect(exits, equals([1]));
      });
    });
  });
}
