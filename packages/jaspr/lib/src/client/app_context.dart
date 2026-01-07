import '../../client.dart';

extension AppContext on BuildContext {
  /// The currently visited url.
  String get url => binding.currentUrl;

  /// Reloads the current page.
  void reload() {
    ClientAppBinding.reload();
  }
}
