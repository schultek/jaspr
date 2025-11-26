import '../framework/framework.dart';

extension AppContext on BuildContext {
  /// The currently visited url.
  String get url => binding.currentUrl;
}
