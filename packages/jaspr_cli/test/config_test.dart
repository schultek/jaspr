import 'package:file/memory.dart';
import 'package:jaspr_cli/src/config.dart';
import 'package:jaspr_cli/src/logging.dart';
import 'package:test/test.dart';

class TestLogger implements Logger {
  TestLogger({this.verbose = false});

  @override
  final bool verbose;

  final messages = <String>[];

  @override
  MasonLogger? get logger => null;

  @override
  void complete(bool success) {}

  @override
  void write(String message, {Tag? tag, Level level = Level.info, ProgressState? progress}) {
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
      test('with correct mode, target and port', () {
        fs.file('pubspec.yaml').writeAsStringSync('''
name: test
dependencies:
  jaspr: any
jaspr:
  mode: server
  target: [lib/main.dart, lib/other.dart]
  port: 8080
''');
        // create target files
        fs.file('lib/main.dart').createSync(recursive: true);
        fs.file('lib/other.dart').createSync(recursive: true);

        expect(project.pubspecYaml, isNotNull);
        expect(project.requirePubspecYaml, isNotNull);
        expect(() => project.requireJasprDependency, isNot(throwsException));
        expect(project.modeOrNull, equals(JasprMode.server));
        expect(project.requireMode, equals(JasprMode.server));
        expect(project.target, equals(['lib/main.dart', 'lib/other.dart']));
        expect(project.port, equals('8080'));
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

      test('with invalid target causes exit', () {
        fs.file('pubspec.yaml').writeAsStringSync('''
name: test
dependencies:
  jaspr: any
jaspr:
  mode: static
  target: 123
''');

        expect(() => project.target, throwsStateError);
        expect(logger.messages, contains('\'jaspr.target\' in pubspec.yaml must be a String or List<String>.'));
        expect(exits, equals([1]));
      });

      test('with missing target file causes exit', () {
        fs.file('pubspec.yaml').writeAsStringSync('''
name: test
dependencies:
  jaspr: any
jaspr:
  mode: static
  target: missing.dart
''');

        expect(() => project.target, throwsStateError);
        expect(
          logger.messages,
          contains('The file "missing.dart" specified by \'jaspr.target\' in pubspec.yaml does not exist.'),
        );
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
  jaspr_web_compilers: any
''');

        expect(() => project.requireJasprDependency, isNot(throwsException));
        expect(() => project.preferJasprBuilderDependency, isNot(throwsException));
        expect(project.usesFlutter, isTrue);
        expect(project.usesJasprWebCompilers, isTrue);
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
        expect(project.usesFlutter, isFalse);
        expect(project.usesJasprWebCompilers, isFalse);
        expect(logger.messages, hasLength(2));
        expect(exits, equals([1]));
      });
    });
  });
}
