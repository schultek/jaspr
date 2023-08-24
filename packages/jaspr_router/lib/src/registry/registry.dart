import '../route.dart';
import 'registry_server.dart' if (dart.library.html) 'registry_stub.dart';

/// Interface for route registration
abstract class RouteRegistry {
  static RouteRegistry instance = RouteRegistryImpl();

  void registerRoutes(List<RouteBase> routes);
}
