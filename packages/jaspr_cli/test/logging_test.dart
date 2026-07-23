import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build_daemon/data/server_log.dart' as s;
import 'package:io/ansi.dart';
import 'package:jaspr_cli/src/logging.dart';
import 'package:test/test.dart';

void main() {
  group('Tag', () {
    test('format with non-ansi output', () {
      overrideAnsiOutput(false, () {
        expect(Tag.cli.format(false, false), equals('[LOG] '));
        expect(Tag.builder.format(false, true), equals('[BUILDER] '));
        expect(Tag.none.format(false, false), equals(''));
      });
    });

    test('format with ansi output enabled', () {
      overrideAnsiOutput(true, () {
        final formatted = Tag.cli.format(false, false);
        expect(
          formatted,
          equals(
            '${backgroundDarkGray.wrap(white.wrap(styleBold.wrap(' L ', forScript: false)!, forScript: false)!, forScript: false)!} ',
          ),
        );
      });

      overrideAnsiOutput(true, () {
        final formatted = Tag.cli.format(false, true);
        expect(
          formatted,
          equals(
            '${backgroundDarkGray.wrap(white.wrap(styleBold.wrap(' LOG     ', forScript: false)!, forScript: false)!, forScript: false)!} ',
          ),
        );
      });
    });
  });

  group('Logger formatMessage', () {
    test('formats info level with tag prefix', () {
      overrideAnsiOutput(false, () {
        final (msg, length) = Logger.formatMessage('hello', Tag.cli, Level.info);
        expect(msg, equals('[LOG] hello'));
        expect(length, equals(6));
      });
    });

    test('formats multi-line messages with aligned indentation', () {
      overrideAnsiOutput(false, () {
        final (msg, length) = Logger.formatMessage('line1\nline2', Tag.cli, Level.info);
        expect(msg, equals('[LOG] line1\n      line2'));
        expect(length, equals(6));
      });
    });

    test('formats warnings and errors with level prefix tags', () {
      overrideAnsiOutput(false, () {
        final (msg, _) = Logger.formatMessage('alert', Tag.cli, Level.warning);
        expect(msg, equals('[LOG] [WARNING] alert'));
      });
    });
  });

  group('LevelFormat', () {
    test('tag returns level prefix', () {
      expect(Level.info.tag, equals(''));
      expect(Level.warning.tag, equals('[WARNING] '));
      expect(Level.error.tag, equals('[ERROR] '));
      expect(Level.critical.tag, equals('[CRITICAL] '));
    });

    test('format applies style/ansi wrapper', () {
      overrideAnsiOutput(false, () {
        expect(Level.info.format('msg'), equals('msg'));
        expect(Level.verbose.format('msg'), equals('msg'));
        expect(Level.warning.format('msg'), equals('msg'));
      });

      overrideAnsiOutput(true, () {
        expect(Level.verbose.format('msg'), equals('\x1b[90mmsg\x1b[0m')); // Gray text
        expect(Level.warning.format('msg'), equals('\x1b[33m\x1b[1mmsg\x1b[22m\x1b[0m')); // Yellow bold
        expect(Level.error.format('msg'), equals('\x1b[91m\x1b[1mmsg\x1b[22m\x1b[0m')); // Light red bold
        expect(
          Level.critical.format('msg'),
          equals('\x1b[41m\x1b[1m\x1b[97mmsg\x1b[0m\x1b[22m\x1b[0m'),
        ); // Background red, bold, white text
      });
    });
  });

  group('ServerLogger', () {
    late TestStdout testStdout;
    late TestStderr testStderr;
    late Logger logger;

    setUp(() {
      testStdout = TestStdout();
      testStderr = TestStderr();
      logger = Logger(true); // verbose logger
    });

    test('writeServerLog converts log levels correctly', () {
      IOOverrides.runZoned(
        () {
          final serverLog = s.ServerLog(
            (b) => b
              ..level = s.Level.WARNING
              ..message = 'Test server warning'
              ..loggerName = 'server'
              ..error = 'Some error info',
          );
          logger.writeServerLog(serverLog);

          expect(testStdout.output, equals(['[BUILDER] [WARNING] Test server warningSome error info']));
          expect(testStderr.output, isEmpty);
        },
        stdout: () => testStdout,
        stderr: () => testStderr,
      );
    });

    test('writeServerLog intercepts Flutter SDK build failure warning', () {
      IOOverrides.runZoned(
        () {
          final serverLog = s.ServerLog(
            (b) => b
              ..level = s.Level.SEVERE
              ..message =
                  'build_web_compilers:entrypoint transitive libraries have sdk dependencies that not supported on this platform flutter|lib'
              ..loggerName = 'builder',
          );
          logger.writeServerLog(serverLog);

          expect(
            testStderr.output,
            equals([
              '[BUILDER] [ERROR] build_web_compilers:entrypoint transitive libraries have sdk dependencies that not supported on this platform flutter|lib',
              '[LOG] [ERROR] Failed to compile some libraries with a dependency on the Flutter SDK. Try setting `jaspr.flutter` to `plugins` in your `pubspec.yaml` file.',
            ]),
          );
          expect(testStdout.output, isEmpty);
        },
        stdout: () => testStdout,
        stderr: () => testStderr,
      );
    });
  });

  group('Logger implementations (No Terminal)', () {
    late TestStdout testStdout;
    late TestStderr testStderr;
    late Logger verboseLogger;
    late Logger normalLogger;

    setUp(() {
      testStdout = TestStdout();
      testStderr = TestStderr();
      verboseLogger = Logger(true);
      normalLogger = Logger(false);
    });

    test('writes standard message to stdout and errors to stderr', () {
      IOOverrides.runZoned(
        () {
          verboseLogger.write('Standard message');
          verboseLogger.write('Error message', level: Level.error);

          expect(testStdout.output, equals(['Standard message']));
          expect(testStderr.output, equals(['[ERROR] Error message']));
        },
        stdout: () => testStdout,
        stderr: () => testStderr,
      );
    });

    test('filters out verbose/debug messages when not verbose', () {
      IOOverrides.runZoned(
        () {
          normalLogger.write('Verbose output', level: Level.verbose);
          normalLogger.write('Info output', level: Level.info);

          expect(testStdout.output, equals(['Info output']));
          expect(testStderr.output, isEmpty);
        },
        stdout: () => testStdout,
        stderr: () => testStderr,
      );
    });

    test('write progress states without terminal supports complete successfully', () {
      IOOverrides.runZoned(
        () {
          normalLogger.write('Compiling', tag: Tag.builder, progress: ProgressState.running);
          normalLogger.write('Compiling', tag: Tag.builder, progress: ProgressState.completed);

          expect(testStdout.output.length, equals(3));
          expect(testStdout.output[0], equals('[BUILDER] Compiling'));
          expect(testStdout.output[1], equals('[BUILDER] Compiling'));
          expect(testStdout.output[2], startsWith('[BUILDER] Compiling ✓'));
          expect(testStderr.output, isEmpty);
        },
        stdout: () => testStdout,
        stderr: () => testStderr,
      );
    });
  });

  group('Logger implementations (Terminal)', () {
    late TerminalStdout termStdout;
    late TerminalStdin termStdin;
    late Logger logger;

    setUp(() {
      termStdout = TerminalStdout();
      termStdin = TerminalStdin();
      logger = Logger(false);
    });

    test('setFooter and clearFooter', () {
      IOOverrides.runZoned(
        () {
          logger.setFooter(['Line 1', 'Line 2']);
          expect(termStdout.output, equals(['Line 1\n', 'Line 2\n']));

          termStdout.output.clear();
          logger.clearFooter();
          expect(termStdout.output, equals(['\x1b[2A\r\x1b[J']));
        },
        stdout: () => termStdout,
        stdin: () => termStdin,
      );
    });

    test('write progress states with terminal runs spinner and timer', () async {
      await IOOverrides.runZoned(
        () async {
          logger.write('Building task', tag: Tag.builder, progress: ProgressState.running);
          // Wait a small bit so spinner timer fires
          await Future<void>.delayed(const Duration(milliseconds: 100));
          logger.write('Building task', tag: Tag.builder, progress: ProgressState.completed);

          final outputCombined = termStdout.output.join('');
          expect(outputCombined, contains('Building task'));
          expect(outputCombined, contains('✓'));
        },
        stdout: () => termStdout,
        stdin: () => termStdin,
      );
    });

    test('prompt returns input and uses default value when empty', () async {
      await IOOverrides.runZoned(
        () async {
          // 1. Normal prompt input
          termStdin.addInput('User Input\n');
          final val1 = await logger.prompt('Enter name');
          expect(val1, equals('User Input'));

          // 2. Empty input returning default value
          termStdin.addInput('\n');
          final val2 = await logger.prompt('Enter name', defaultValue: 'DefaultName');
          expect(val2, equals('DefaultName'));
        },
        stdout: () => termStdout,
        stdin: () => termStdin,
      );
    });

    test('confirm returns true/false based on input and default value', () async {
      await IOOverrides.runZoned(
        () async {
          // 1. Confirm 'y' -> true
          termStdin.addInput('y\n');
          final confirmY = await logger.confirm('Continue?', defaultValue: false);
          expect(confirmY, isTrue);

          // 2. Confirm 'n' -> false
          termStdin.addInput('no\n');
          final confirmN = await logger.confirm('Continue?', defaultValue: true);
          expect(confirmN, isFalse);

          // 3. Confirm empty -> default (true)
          termStdin.addInput('\n');
          final confirmDefault = await logger.confirm('Continue?', defaultValue: true);
          expect(confirmDefault, isTrue);

          // 4. Confirm with hint
          termStdin.addInput('yes\n');
          final confirmHint = await logger.confirm('Continue?', defaultValue: false, hint: 'Select yes');
          expect(confirmHint, isTrue);
        },
        stdout: () => termStdout,
        stdin: () => termStdin,
      );
    });

    test('chooseOne chooses option with arrow keys and Enter', () async {
      await IOOverrides.runZoned(
        () async {
          // Simulate: Down Arrow (27, 91, 66), then Enter (10)
          termStdin.addBytes([27, 91, 66, 10]);

          final choice = await logger.chooseOne(
            'Select color',
            choices: ['Red', 'Green', 'Blue'],
          );

          expect(choice, equals('Green')); // Second option selected
        },
        stdout: () => termStdout,
        stdin: () => termStdin,
      );
    });
  });
}

// Minimal stub for non-terminal Stdout
class TestStdout implements Stdout {
  final List<String> output = [];

  @override
  bool get hasTerminal => false;

  @override
  bool get supportsAnsiEscapes => false;

  @override
  void writeln([Object? object = '']) {
    output.add(object?.toString() ?? '');
  }

  @override
  void write(Object? object) {
    output.add(object?.toString() ?? '');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Minimal stub for non-terminal Stderr
class TestStderr extends TestStdout implements Stdout {}

// Minimal stub for terminal Stdout
class TerminalStdout implements Stdout {
  final List<String> output = [];

  @override
  bool get hasTerminal => true;

  @override
  int get terminalColumns => 80;

  @override
  int get terminalLines => 24;

  @override
  bool get supportsAnsiEscapes => true;

  @override
  void writeln([Object? object = '']) {
    output.add('${object?.toString() ?? ''}\n');
  }

  @override
  void write(Object? object) {
    output.add(object?.toString() ?? '');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Minimal stub for terminal Stdin
class TerminalStdin extends Stream<List<int>> implements Stdin {
  final _controller = StreamController<List<int>>();

  void addInput(String text) {
    _controller.add(utf8.encode(text));
  }

  void addBytes(List<int> bytes) {
    _controller.add(bytes);
  }

  @override
  bool lineMode = true;

  @override
  bool echoMode = true;

  @override
  bool get hasTerminal => true;

  @override
  bool get supportsAnsiEscapes => true;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _controller.stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
