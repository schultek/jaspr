import 'package:frontend_theme/theme.dart';
import 'package:jaspr/jaspr.dart';

class ThemeToggle extends StatefulComponent {
  const ThemeToggle({super.key});

  @override
  State createState() => ThemeToggleState();
}

class ThemeToggleState extends State<ThemeToggle> {
  bool isDark = false;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(styles: Styles().flexbox(justifyContent: JustifyContent.end).box(margin: EdgeInsets.all(2.em)), [
      button(onClick: () {
        final theme = Theme.of(context);
        if (theme.current == ThemeMode.light) {
          theme.update(ThemeMode.dark);
        } else {
          theme.update(ThemeMode.light);
        }
      }, styles: Styles().box(width: 6.em), [text('Toggle Theme')])
    ]);
  }
}
