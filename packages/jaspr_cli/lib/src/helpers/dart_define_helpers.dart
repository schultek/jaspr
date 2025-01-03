
import '../commands/base_command.dart';

extension AddDartDefine on BaseCommand {
  void addDartDefineArgs() {
    argParser.addMultiOption('dart-define',
      help: 'Additional key-value pairs that will be available both on the server and client as constants from the String.fromEnvironment, bool.fromEnvironment, and int.fromEnvironment constructors. Multiple defines can be passed by repeating "--dart-define" multiple times.',
      valueHelp: 'key=value',
      splitCommas: false,
    );
    argParser.addMultiOption('dart-define-client',
      help: 'Additional key-value pairs that will be available on the client as constants from the String.fromEnvironment, bool.fromEnvironment, and int.fromEnvironment constructors. Multiple defines can be passed by repeating "--dart-define-client" multiple times.',
      valueHelp: 'key=value',
      splitCommas: false,
    );
    argParser.addMultiOption('dart-define-server',
      help: 'Additional key-value pairs that will be available on the server as constants from the String.fromEnvironment, bool.fromEnvironment, and int.fromEnvironment constructors. Multiple defines can be passed by repeating "--dart-define-client" multiple times.',
      valueHelp: 'key=value',
      splitCommas: false,
    );
  }

  Map<String, String> getClientDartDefines() {
    final defines = argResults?['dart-define'] as List<String>? ?? [];
    final clientDefines = argResults?['dart-define-client'] as List<String>? ?? [];
    return _parseDefines(defines.followedBy(clientDefines));
  }

  Map<String, String> getServerDartDefines() {
    final defines = argResults?['dart-define'] as List<String>? ?? [];
    final serverDefines = argResults?['dart-define-server'] as List<String>? ?? [];
    return _parseDefines(defines.followedBy(serverDefines));
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