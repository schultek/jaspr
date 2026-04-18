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
  Future<void> setSelection(String id) async {}
}
