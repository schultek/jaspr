import 'package:recase/recase.dart';

import '../../browser.dart';

mixin BaseTheme {
  String getName();
}

class Var<T> {
  const Var(this.value);

  final T value;
}

mixin AppThemeMixin on Enum {
  get color => Color.variable('--${name.paramCase}');

  get unit => Unit.variable('--${name.paramCase}');

  get fontFamily => FontFamily.variable('--${name.paramCase}');
}

class ThemeUtils {
  static StyleRule getStyles(
    List<AppThemeMixin> themeValues,
    List<BaseTheme> themeModes,
    Var? Function(BaseTheme, dynamic) getStyleByMode,
  ) {
    return css('body', [
      for (BaseTheme mode in themeModes)
        css('&[data-theme=\'${mode.getName()}\']').raw({
          for (var style in themeValues) '--${style.name.paramCase}': getStyleByMode(mode, style)!.value.value,
        }),
    ]);
  }
}

@client
class ThemeProvider extends StatefulComponent {
  const ThemeProvider({
    super.key,
    required this.child,
    required this.theme,
  });

  final Component child;
  final BaseTheme theme;

  @override
  State createState() => ThemeProviderState();
}

class ThemeProviderState extends State<ThemeProvider> {
  late BaseTheme current;

  @override
  void initState() {
    super.initState();
    current = component.theme;
  }

  update(BaseTheme theme) {
    setState(() => current = theme);
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Document.body(attributes: {
      'data-theme': current.getName(),
    });
    yield Theme(
      theme: current,
      update: update,
      child: component.child,
    );
  }
}

class Theme extends InheritedComponent {
  const Theme({
    super.key,
    required super.child,
    required BaseTheme theme,
    required this.update,
  }) : _theme = theme;

  final BaseTheme _theme;
  final void Function(BaseTheme) update;

  BaseTheme get current => _theme;

  static Theme of(BuildContext context) {
    final Theme? result = context.dependOnInheritedComponentOfExactType<Theme>();
    assert(result != null, 'No Theme found in context. Please wrap your app with "ThemeProvider".');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant Theme oldComponent) {
    return !identical(_theme, oldComponent._theme);
  }
}
