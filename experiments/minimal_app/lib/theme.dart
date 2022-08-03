import 'package:jaspr/jaspr.dart';

import 'theme_server.dart' if (dart.library.html) 'theme_web.dart';

export 'theme_server.dart' if (dart.library.html) 'theme_web.dart';

class Theme {
  static T of<T extends ThemeData>(BuildContext context) {
    return context.dependOnInheritedComponentOfExactType<StaticTheme>()!.theme as T;
  }
}
