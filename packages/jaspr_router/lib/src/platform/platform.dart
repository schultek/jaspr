import 'package:jaspr/jaspr.dart';

import '../route.dart';
import 'platform_server.dart' if (dart.library.js_interop) 'platform_web.dart';

/// Interface for platform router.
abstract class PlatformRouter {
  static PlatformRouter instance = PlatformRouterImpl();

  HistoryManager get history;

  RouteRegistry get registry;

  void redirect(BuildContext context, String url);
}

/// Interface for history management
/// Will be implemented separately on browser and server
abstract class HistoryManager {
  /// Initialize the history manager and setup any listeners to history changes
  void init(BuildContext context, {void Function(Object? state, {String? url})? onChangeState});

  /// Push a new state to the history
  void push(String url, {String? title, Object? data});

  /// Replace the current history state
  void replace(String url, {String? title, Object? data});

  /// Go back in the history
  void back();
}

abstract class RouteRegistry {
  Future<void> registerRoutes(List<RouteBase> routes);
}
