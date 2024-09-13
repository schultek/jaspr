import 'package:recase/recase.dart';

import '../../browser.dart';

class ThemeData<T extends Enum> {
  const ThemeData({
    required this.name,
    required this.data,
  });

  final String name;
  final Map<T, Color> data;

  static Color getColorValue(String name) => Color.variable('--${name.paramCase}');

  StyleRule get cssStyles {
    return css('&[data-theme=\'$name\']').raw({
      for (var style in data.entries) '--${style.key.name.paramCase}': style.value.value,
    });
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
  final ThemeData theme;

  @override
  State createState() => ThemeProviderState();
}

class ThemeProviderState extends State<ThemeProvider> {
  late ThemeData current;

  @override
  void initState() {
    super.initState();
    current = component.theme;
  }

  update(ThemeData theme) {
    setState(() => current = theme);
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Document.body(attributes: {
      'data-theme': current.name,
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
    required ThemeData theme,
    required this.update,
  }) : _theme = theme;

  final ThemeData _theme;
  final void Function(ThemeData) update;

  ThemeData get current => _theme;

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
