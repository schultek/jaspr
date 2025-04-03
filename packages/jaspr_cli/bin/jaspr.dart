import 'dart:io';

import 'package:jaspr_cli/src/command_runner.dart';

void main(List<String> args) async {
  try {
    var result = await JasprCommandRunner().run(args);
    await flushThenExit(result ?? 0);
  } catch (e, stackTrace) {
    stderr.writeln('Error: $e');
    stderr.writeln('Stack trace: $stackTrace');
    await flushThenExit(1);
  }
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
