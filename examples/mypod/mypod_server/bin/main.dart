import 'dart:io';

import 'package:mypod_server/src/server.dart';

/// This is the starting point for your Serverpod server. Typically, there is
/// no need to modify this file.
void main(List<String> args) {
  print(Platform.environment['jaspr_dev_proxy']);
  run(args);
}
