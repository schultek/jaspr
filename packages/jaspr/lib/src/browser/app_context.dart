import '../framework/framework.dart';
import 'browser_binding.dart';

extension AppContext on BuildContext {
  BrowserAppBinding get _binding => binding as BrowserAppBinding;

  /// The currently visited url.
  String get url => binding.currentUrl;

  /// Reloads the current page.
  void reload() {
    _binding.reload();
  }
}
