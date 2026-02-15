import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:jaspr_cli/src/commands/base_command.dart';
import 'package:jaspr_cli/src/helpers/dart_define_helpers.dart';
import 'package:test/test.dart';

// Test command that exposes dart define functionality
class TestCommand extends BaseCommand {
  TestCommand({super.logger}) {
    addDartDefineArgs();
  }

  @override
  String get name => 'test';

  @override
  String get description => 'Test command';

  // Store defines when command runs (to trigger parsing during execution)
  late Map<String, String> _clientDefines;
  late Map<String, String> _serverDefines;

  @override
  Future<int> runCommand() async {
    // Access defines during command execution to trigger parsing
    _clientDefines = getClientDartDefines();
    _serverDefines = getServerDartDefines();
    return 0;
  }

  // Expose methods for testing
  Map<String, String> get clientDefines => _clientDefines;
  Map<String, String> get serverDefines => _serverDefines;
}

void main() {
  late Directory tempDir;
  late CommandRunner<int> runner;
  late TestCommand command;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('dart_define_test_');
    command = TestCommand();
    runner = CommandRunner<int>('jaspr', 'Test')..addCommand(command);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('--dart-define-from-file', () {
    group('JSON format', () {
      test('parses simple JSON object', () async {
        final file = File('${tempDir.path}/config.json');
        file.writeAsStringSync('{"API_KEY": "secret123", "DEBUG": "true"}');

        await runner.run(['test', '--dart-define-from-file=${file.path}']);

        expect(command.clientDefines, {
          'API_KEY': 'secret123',
          'DEBUG': 'true',
        });
      });

      test('converts non-string values to strings', () async {
        final file = File('${tempDir.path}/config.json');
        file.writeAsStringSync('{"count": 42, "enabled": true, "rate": 3.14}');

        await runner.run(['test', '--dart-define-from-file=${file.path}']);

        expect(command.clientDefines, {
          'count': '42',
          'enabled': 'true',
          'rate': '3.14',
        });
      });

      test('throws on invalid JSON', () async {
        final file = File('${tempDir.path}/config.json');
        file.writeAsStringSync('{invalid json}');

        await expectLater(
          runner.run(['test', '--dart-define-from-file=${file.path}']),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws on JSON array (not object)', () async {
        final file = File('${tempDir.path}/config.json');
        file.writeAsStringSync('["item1", "item2"]');

        await expectLater(
          runner.run(['test', '--dart-define-from-file=${file.path}']),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('.env format', () {
      test('parses basic key=value pairs', () async {
        final file = File('${tempDir.path}/.env');
        file.writeAsStringSync('API_KEY=secret123\nDEBUG=true');

        await runner.run(['test', '--dart-define-from-file=${file.path}']);

        expect(command.clientDefines, {
          'API_KEY': 'secret123',
          'DEBUG': 'true',
        });
      });

      test('ignores comment lines', () async {
        final file = File('${tempDir.path}/.env');
        file.writeAsStringSync('# This is a comment\nAPI_KEY=secret\n# Another comment');

        await runner.run(['test', '--dart-define-from-file=${file.path}']);

        expect(command.clientDefines, {'API_KEY': 'secret'});
      });

      test('ignores empty lines', () async {
        final file = File('${tempDir.path}/.env');
        file.writeAsStringSync('KEY1=value1\n\n\nKEY2=value2');

        await runner.run(['test', '--dart-define-from-file=${file.path}']);

        expect(command.clientDefines, {
          'KEY1': 'value1',
          'KEY2': 'value2',
        });
      });

      test('handles double-quoted values', () async {
        final file = File('${tempDir.path}/.env');
        file.writeAsStringSync('MESSAGE="Hello World"');

        await runner.run(['test', '--dart-define-from-file=${file.path}']);

        expect(command.clientDefines, {'MESSAGE': 'Hello World'});
      });

      test('handles single-quoted values', () async {
        final file = File('${tempDir.path}/.env');
        file.writeAsStringSync("MESSAGE='Hello World'");

        await runner.run(['test', '--dart-define-from-file=${file.path}']);

        expect(command.clientDefines, {'MESSAGE': 'Hello World'});
      });

      test('handles backtick-quoted values', () async {
        final file = File('${tempDir.path}/.env');
        file.writeAsStringSync('MESSAGE=`Hello World`');

        await runner.run(['test', '--dart-define-from-file=${file.path}']);

        expect(command.clientDefines, {'MESSAGE': 'Hello World'});
      });

      test('handles inline comments after unquoted values', () async {
        final file = File('${tempDir.path}/.env');
        file.writeAsStringSync('API_KEY=secret # this is my key');

        await runner.run(['test', '--dart-define-from-file=${file.path}']);

        expect(command.clientDefines, {'API_KEY': 'secret'});
      });

      test('preserves # in quoted values', () async {
        final file = File('${tempDir.path}/.env');
        file.writeAsStringSync('COLOR="#FF0000"');

        await runner.run(['test', '--dart-define-from-file=${file.path}']);

        expect(command.clientDefines, {'COLOR': '#FF0000'});
      });

      test('handles empty values', () async {
        final file = File('${tempDir.path}/.env');
        file.writeAsStringSync('EMPTY_KEY=');

        await runner.run(['test', '--dart-define-from-file=${file.path}']);

        expect(command.clientDefines, {'EMPTY_KEY': ''});
      });

      test('handles keys with underscores and numbers', () async {
        final file = File('${tempDir.path}/.env');
        file.writeAsStringSync('_PRIVATE_KEY_123=value');

        await runner.run(['test', '--dart-define-from-file=${file.path}']);

        expect(command.clientDefines, {'_PRIVATE_KEY_123': 'value'});
      });
    });

    group('file handling', () {
      test('throws on non-existent file', () async {
        await expectLater(
          runner.run(['test', '--dart-define-from-file=/nonexistent/path.json']),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('supports multiple files', () async {
        final file1 = File('${tempDir.path}/config1.json');
        file1.writeAsStringSync('{"KEY1": "value1"}');

        final file2 = File('${tempDir.path}/config2.json');
        file2.writeAsStringSync('{"KEY2": "value2"}');

        await runner.run([
          'test',
          '--dart-define-from-file=${file1.path}',
          '--dart-define-from-file=${file2.path}',
        ]);

        expect(command.clientDefines, {
          'KEY1': 'value1',
          'KEY2': 'value2',
        });
      });

      test('later files override earlier files', () async {
        final file1 = File('${tempDir.path}/config1.json');
        file1.writeAsStringSync('{"KEY": "first"}');

        final file2 = File('${tempDir.path}/config2.json');
        file2.writeAsStringSync('{"KEY": "second"}');

        await runner.run([
          'test',
          '--dart-define-from-file=${file1.path}',
          '--dart-define-from-file=${file2.path}',
        ]);

        expect(command.clientDefines, {'KEY': 'second'});
      });
    });

    group('precedence', () {
      test('CLI --dart-define overrides file values', () async {
        final file = File('${tempDir.path}/config.json');
        file.writeAsStringSync('{"API_KEY": "from_file", "OTHER": "value"}');

        await runner.run([
          'test',
          '--dart-define-from-file=${file.path}',
          '--dart-define=API_KEY=from_cli',
        ]);

        expect(command.clientDefines, {
          'API_KEY': 'from_cli',
          'OTHER': 'value',
        });
      });

      test('CLI --dart-define-client overrides file values for client', () async {
        final file = File('${tempDir.path}/config.json');
        file.writeAsStringSync('{"KEY": "from_file"}');

        await runner.run([
          'test',
          '--dart-define-from-file=${file.path}',
          '--dart-define-client=KEY=client_override',
        ]);

        expect(command.clientDefines, {'KEY': 'client_override'});
        expect(command.serverDefines, {'KEY': 'from_file'});
      });

      test('CLI --dart-define-server overrides file values for server', () async {
        final file = File('${tempDir.path}/config.json');
        file.writeAsStringSync('{"KEY": "from_file"}');

        await runner.run([
          'test',
          '--dart-define-from-file=${file.path}',
          '--dart-define-server=KEY=server_override',
        ]);

        expect(command.clientDefines, {'KEY': 'from_file'});
        expect(command.serverDefines, {'KEY': 'server_override'});
      });
    });

    group('auto-detection', () {
      test('detects JSON by leading brace even with .env extension', () async {
        final file = File('${tempDir.path}/config.env');
        file.writeAsStringSync('{"KEY": "json_value"}');

        await runner.run(['test', '--dart-define-from-file=${file.path}']);

        expect(command.clientDefines, {'KEY': 'json_value'});
      });

      test('detects .env format by default', () async {
        final file = File('${tempDir.path}/config.txt');
        file.writeAsStringSync('KEY=env_value');

        await runner.run(['test', '--dart-define-from-file=${file.path}']);

        expect(command.clientDefines, {'KEY': 'env_value'});
      });

      test('handles whitespace before JSON brace', () async {
        final file = File('${tempDir.path}/config.json');
        file.writeAsStringSync('  \n  {"KEY": "value"}');

        await runner.run(['test', '--dart-define-from-file=${file.path}']);

        expect(command.clientDefines, {'KEY': 'value'});
      });
    });
  });
}
