import 'package:jaspr/jaspr.dart';

import 'theme_server.dart' if (dart.library.html) 'theme_web.dart';

export 'theme_server.dart' if (dart.library.html) 'theme_web.dart';

class ThemedComponent extends DomComponent {
  ThemedComponent({required super.tag, ResolvedThemeData? theme, super.events, super.child, super.children})
      : super(classes: [...?theme?.classes]);
}

class Theme {
  static T of<T extends ThemeData>(BuildContext context) {
    return context.dependOnInheritedComponentOfExactType<StaticTheme>()!.theme as T;
  }
}
