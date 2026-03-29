import 'package:jaspr/client.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'main.client.options.dart';
import 'src/components/layout.dart';
import 'src/pages/component_tree_page.dart';
import 'src/pages/main_app_state.dart';
import 'src/services/component_tree_service.dart';
import 'src/services/dev_tools_service.dart';

void main() {
  Jaspr.initializeApp(options: defaultClientOptions);

  runApp(DevToolsApp());
}

class DevToolsApp extends StatefulComponent {
  const DevToolsApp({super.key});

  @override
  State<DevToolsApp> createState() => _DevToolsAppState();
}

class _DevToolsAppState extends State<DevToolsApp> {
  late JasprDevToolsService _service;
  late ComponentTreeService _treeService;

  @override
  void initState() {
    super.initState();
    _service = JasprDevToolsService();
    _treeService = ComponentTreeService(_service);
  }

  @override
  void dispose() {
    _treeService.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return MainAppState(
      service: _service,
      treeService: _treeService,
      child: Router(
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainLayout(child: child),
            routes: [
              Route(
                path: '/',
                builder: (context, state) => const ComponentTreePage(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
