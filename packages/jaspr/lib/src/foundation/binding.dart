import '../framework/framework.dart';
import 'scheduler.dart';

/// Main class that provide services (also known as "bindings").
abstract class AppBinding with SchedulerBinding {
  AppBinding();

  /// Whether the current app is run on the client (in the browser)
  bool get isClient;

  /// The currently active url.
  ///
  /// On the server, this is the request url.
  /// On the client, this is the currently visited url in the browser.
  String get currentUrl;

  /// The [Element] that is at the root of the hierarchy.
  ///
  /// This is initialized when `runApp` is called.
  Element? get rootElement;

  /// Report an error that occurred during the build process of [element].
  void reportBuildError(Element element, Object error, StackTrace stackTrace);
}
