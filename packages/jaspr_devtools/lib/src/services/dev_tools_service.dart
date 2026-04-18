import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:vm_service/vm_service.dart';

import 'dev_tools_service_web.dart' if (dart.library.io) 'dev_tools_service_vm.dart';

enum ProjectMode { client, server, static }

abstract class DevToolsService with ChangeNotifier {
  ProjectMode get projectMode;

  VmService? get clientVmService;
  VmService? get serverVmService;

  static DevToolsService instance = DevToolsServiceImpl();

  Future<void> setSelection(String id);
}
