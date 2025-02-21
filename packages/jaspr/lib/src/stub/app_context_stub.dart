import '../framework/framework.dart';

extension AppContext on BuildContext {
  /// The currently active url.
  ///
  /// On the server, this is the request url.
  /// On the client, this is the currently visited url in the browser.
  String get url {
    throw UnimplementedError('Should be overridden on client and server.');
  }
}
