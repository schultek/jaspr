import 'package:vm_service/vm_service.dart';

import 'dev_tools_service.dart';

class DevToolsServiceImpl extends DevToolsService {
  @override
  ProjectMode get projectMode => ProjectMode.server;

  @override
  VmService? get clientVmService => null;

  @override
  VmService? get serverVmService => null;

  @override
  Future<Map<String, dynamic>?> getClientTree() async => null;

  @override
  Future<Map<String, dynamic>?> getServerTree(String id) async => null;

  @override
  Future<void> setSelection(String id) async {}

  @override
  Future<void> updateProperty(String id, String target, String property, dynamic value) async {}
}
