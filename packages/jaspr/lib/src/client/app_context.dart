import '../../client.dart';

extension AppContext on BuildContext {
  ClientAppBinding get _binding => binding as ClientAppBinding;

  /// The currently visited url.
  String get url => binding.currentUrl;

  /// Reloads the current page.
  void reload([String? path]) {
    _binding.reload(path);
  }
}
