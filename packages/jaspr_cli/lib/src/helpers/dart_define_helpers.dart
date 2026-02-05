import 'dart:convert';
import 'dart:io';

import '../commands/base_command.dart';

/// Regex patterns for parsing .env files (matches Flutter's implementation).
abstract class _DotEnvRegex {
  // Dot env multi-line block value regex (to reject)
  static final multiLineBlock = RegExp(r'^\s*([a-zA-Z_]+[a-zA-Z0-9_]*)\s*=\s*"""\s*(.*)$');

  // Dot env full line value regex (eg FOO=bar)
  static final keyValue = RegExp(r'^\s*([a-zA-Z_]+[a-zA-Z0-9_]*)\s*=\s*(.*)?$');

  // Dot env value wrapped in double quotes regex (eg FOO="bar")
  static final doubleQuotedValue = RegExp(r'^"(.*)"\s*(\#\s*.*)?$');

  // Dot env value wrapped in single quotes regex (eg FOO='bar')
  static final singleQuotedValue = RegExp(r"^'(.*)'\s*(\#\s*.*)?$");

  // Dot env value wrapped in back quotes regex (eg FOO=`bar`)
  static final backQuotedValue = RegExp(r'^`(.*)`\s*(\#\s*.*)?$');

  // Dot env value without quotes regex (eg FOO=bar)
  static final unquotedValue = RegExp(r'^([^#\n\s]*)\s*(?:\s*#\s*(.*))?$');
}

extension AddDartDefine on BaseCommand {
  void addDartDefineArgs() {
    argParser.addMultiOption(
      'dart-define',
      help:
          'Additional key-value pairs that will be available both on the server and client as constants\n'
          'from the String.fromEnvironment, bool.fromEnvironment, and int.fromEnvironment constructors.\n'
          'Multiple defines can be passed by repeating "--dart-define" multiple times.',
      valueHelp: 'key=value',
      splitCommas: false,
    );
    argParser.addMultiOption(
      'dart-define-client',
      help:
          'Additional key-value pairs that will be available on the client as constants\n'
          'from the String.fromEnvironment, bool.fromEnvironment, and int.fromEnvironment constructors.\n'
          'Multiple defines can be passed by repeating "--dart-define-client" multiple times.',
      valueHelp: 'key=value',
      splitCommas: false,
    );
    argParser.addMultiOption(
      'dart-define-server',
      help:
          'Additional key-value pairs that will be available on the server as constants\n'
          'from the String.fromEnvironment, bool.fromEnvironment, and int.fromEnvironment constructors.\n'
          'Multiple defines can be passed by repeating "--dart-define-server" multiple times.',
      valueHelp: 'key=value',
      splitCommas: false,
    );
    argParser.addMultiOption(
      'dart-define-from-file',
      help:
          'The path of a .json or .env file containing key-value pairs that will be available as environment variables.\n'
          'These can be accessed using the String.fromEnvironment, bool.fromEnvironment, and int.fromEnvironment constructors.\n'
          'Multiple files can be passed by repeating "--dart-define-from-file" multiple times.\n'
          'Entries from "--dart-define" with identical keys take precedence over entries from these files.',
      valueHelp: 'config.json|.env',
      splitCommas: false,
    );
  }

  Map<String, String> getClientDartDefines() {
    // 1. Load from files first (can be overridden by CLI)
    final fileDefines = _extractDefinesFromFiles();
    // 2. CLI defines override file values
    final defines = argResults?.multiOption('dart-define') ?? [];
    final clientDefines = argResults?.multiOption('dart-define-client') ?? [];
    return {
      ...fileDefines,
      ..._parseDefines(defines.followedBy(clientDefines)),
    };
  }

  Map<String, String> getServerDartDefines() {
    // 1. Load from files first (can be overridden by CLI)
    final fileDefines = _extractDefinesFromFiles();
    // 2. CLI defines override file values
    final defines = argResults?.multiOption('dart-define') ?? [];
    final serverDefines = argResults?.multiOption('dart-define-server') ?? [];
    return {
      ...fileDefines,
      ..._parseDefines(defines.followedBy(serverDefines)),
    };
  }

  Map<String, String> _extractDefinesFromFiles() {
    final result = <String, String>{};
    final filePaths = argResults?.multiOption('dart-define-from-file') ?? [];

    for (final path in filePaths) {
      final file = File(path);
      if (!file.existsSync()) {
        throw ArgumentError.value(
          path,
          'dart-define-from-file',
          'File not found',
        );
      }

      final configRaw = file.readAsStringSync();

      // Determine format: JSON or .env (Flutter's approach)
      Map<String, String> parsed;
      if (configRaw.trim().startsWith('{')) {
        parsed = _parseJsonConfig(configRaw, path);
      } else {
        parsed = _parseEnvConfig(configRaw, path);
      }

      result.addAll(parsed);
    }

    return result;
  }

  Map<String, String> _parseJsonConfig(String content, String filePath) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) {
        throw ArgumentError.value(
          filePath,
          'dart-define-from-file',
          'JSON file must contain an object',
        );
      }
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } on FormatException catch (e) {
      throw ArgumentError.value(
        filePath,
        'dart-define-from-file',
        'Unable to parse JSON: ${e.message}',
      );
    }
  }

  Map<String, String> _parseEnvConfig(String content, String filePath) {
    final lines = content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .where((line) => !line.startsWith('#'));

    final result = <String, String>{};
    for (final line in lines) {
      final entry = _parseEnvProperty(line, filePath);
      result[entry.key] = entry.value;
    }
    return result;
  }

  MapEntry<String, String> _parseEnvProperty(String line, String filePath) {
    // Reject multi-line values
    if (_DotEnvRegex.multiLineBlock.hasMatch(line)) {
      throw ArgumentError.value(
        filePath,
        'dart-define-from-file',
        'Multi-line value is not supported: $line',
      );
    }

    final keyValueMatch = _DotEnvRegex.keyValue.firstMatch(line);
    if (keyValueMatch == null) {
      throw ArgumentError.value(
        filePath,
        'dart-define-from-file',
        'Invalid property line: $line',
      );
    }

    final key = keyValueMatch.group(1)!;
    final value = keyValueMatch.group(2) ?? '';

    // Try each quote style in order
    final doubleQuotedMatch = _DotEnvRegex.doubleQuotedValue.firstMatch(value);
    if (doubleQuotedMatch != null) {
      return MapEntry(key, doubleQuotedMatch.group(1)!);
    }

    final singleQuotedMatch = _DotEnvRegex.singleQuotedValue.firstMatch(value);
    if (singleQuotedMatch != null) {
      return MapEntry(key, singleQuotedMatch.group(1)!);
    }

    final backQuotedMatch = _DotEnvRegex.backQuotedValue.firstMatch(value);
    if (backQuotedMatch != null) {
      return MapEntry(key, backQuotedMatch.group(1)!);
    }

    final unquotedMatch = _DotEnvRegex.unquotedValue.firstMatch(value);
    if (unquotedMatch != null) {
      return MapEntry(key, unquotedMatch.group(1)!);
    }

    return MapEntry(key, value);
  }

  Map<String, String> _parseDefines(Iterable<String> defines) {
    return defines.fold<Map<String, String>>({}, (map, define) {
      final parts = define.split('=');
      if (parts.length != 2) {
        throw ArgumentError.value(define, 'dart-define', 'Must be in the format key=value');
      }
      map[parts[0]] = parts[1];
      return map;
    });
  }
}
