import 'package:jaspr/jaspr.dart';

import '../services/component_tree_service.dart';
import '../services/dev_tools_service.dart';

class MainAppState extends InheritedComponent {
  const MainAppState({
    required this.service,
    required this.treeService,
    required super.child,
    super.key,
  });

  final JasprDevToolsService service;
  final ComponentTreeService treeService;

  static MainAppState of(BuildContext context) {
    return context.dependOnInheritedComponentOfExactType<MainAppState>()!;
  }

  @override
  bool updateShouldNotify(MainAppState oldWidget) {
    return service != oldWidget.service || treeService != oldWidget.treeService;
  }
}
