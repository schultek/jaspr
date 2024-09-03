import 'dart:isolate';

import 'package:custom_lint/src/analyzer_plugin_starter.dart';

Future<void> main(List<String> args, SendPort sendPort) async {
  await start(args, sendPort);
}
