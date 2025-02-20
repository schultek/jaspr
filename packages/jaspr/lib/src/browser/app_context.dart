import 'package:universal_web/web.dart';

import '../framework/framework.dart';

extension AppContext on BuildContext {
  static final String _baseOrigin = () {
    var base = document.querySelector('head>base') as HTMLBaseElement?;
    return base?.href ?? window.location.origin;
  }();

  /// The currently visited url.
  String get url {
    if (_baseOrigin.length > window.location.href.length) {
      return '/';
    }
    var pathWithoutOrigin = window.location.href.substring(_baseOrigin.length);
    if (!pathWithoutOrigin.startsWith('/')) {
      pathWithoutOrigin = '/$pathWithoutOrigin';
    }
    return pathWithoutOrigin;
  }
}
