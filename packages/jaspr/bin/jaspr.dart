import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:jaspr/src/commands/build_command.dart';
import 'package:jaspr/src/commands/create_command.dart';
import 'package:jaspr/src/commands/serve_command.dart';

void main(List<String> args) async {
  var runner = CommandRunner<void>("jaspr", "An experimental web framework for dart apps, supporting SPA and SSR.")
    ..addCommand(CreateCommand())
    ..addCommand(ServeCommand())
    ..addCommand(BuildCommand());

  try {
    await runner.run(args);
    exit(0);
  } on UsageException catch (e) {
    print('${e.message}\n${e.usage}');
    exit(1);
  } catch (e, st) {
    print('$e\n$st');
    exit(1);
  }
}
