import '../framework/framework.dart';
import 'scheduler.dart';

/// Main class that provide services (also known as
/// "bindings").
abstract class AppBinding with SchedulerBinding {
  AppBinding();

  /// Whether the current app is run on the client (in the browser)
  bool get isClient;

  /// The [Element] that is at the root of the hierarchy.
  ///
  /// This is initialized when [runApp] is called.
  Element? get rootElement;
}
