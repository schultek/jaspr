import 'package:frontend_theme/constants/theme.dart';
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
    yield div(styles: Styles().flexbox(justifyContent: JustifyContent.end).box(margin: EdgeInsets.all(1.em)), [
      button(onClick: () {
        final theme = Theme.of(context);
        if (theme.current == ThemeMode.light) {
          theme.update(ThemeMode.dark);
        } else {
          theme.update(ThemeMode.light);
        }
      }, styles: Styles().box(width: 10.em, padding: EdgeInsets.symmetric(vertical: 0.5.em, horizontal: 1.em)), [
        text('Toggle Theme (current: ${Theme.of(context).current.getName()})'),
      ])
    ]);
  }
}
