import '../route.dart';
import 'platform_server.dart' if (dart.library.html) 'platform_web.dart';

/// Interface for platform router.
abstract class PlatformRouter {
  static PlatformRouter instance = PlatformRouterImpl();

  HistoryManager get history;

  RouteRegistry get registry;
}

/// Interface for history management
/// Will be implemented separately on browser and server
abstract class HistoryManager {
  /// Initialize the history manager and setup any listeners to history changes
  void init(String location, void Function(String url) onChange);

  /// Push a new state to the history
  void push(String url, {String? title, Object? data});

  /// Replace the current history state
  void replace(String url, {String? title, Object? data});

  /// Go back in the history
  void back();
}

abstract class RouteRegistry {
  void registerRoutes(List<RouteBase> routes);
}
