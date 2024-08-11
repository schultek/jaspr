import 'dart:io';

import 'package:jaspr_cli/src/command_runner.dart';
import 'package:jaspr_cli/src/commands/base_command.dart';

void main(List<String> args) async {
  var result = await JasprCommandRunner().run(args);
  await flushThenExit(await result.done);
}

/// Flushes the stdout and stderr streams, then exits the program with the given
/// status code.
///
/// This returns a Future that will never complete, since the program will have
/// exited already. This is useful to prevent Future chains from proceeding
/// after you've decided to exit.
Future<dynamic> flushThenExit(int status) {
  return Future.wait<void>([stdout.close(), stderr.close()]).then<void>((_) => exit(status));
}
