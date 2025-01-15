import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import 'icon.dart';

@client
class ThemeToggle extends StatefulComponent {
  const ThemeToggle({super.key});

  @override
  State createState() => ThemeToggleState();
}

class ThemeToggleState extends State<ThemeToggle> {
  bool isDark = false;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) return;

    if (web.window.localStorage.getItem('active-theme') case final theme?) {
      isDark = theme == 'dark';
    } else if (web.window.matchMedia('(prefers-color-scheme: dark)').matches) {
      isDark = true;
    }
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (kIsWeb) {
      yield Document.html(attributes: {'data-theme': isDark ? 'dark' : 'light'});
    }
    yield button(
      classes: 'theme-toggle',
      onClick: () {
        setState(() {
          isDark = !isDark;
          web.window.localStorage.setItem('active-theme', isDark ? 'dark' : 'light');
        });
      },
      styles: !kIsWeb ? Styles.box(visibility: Visibility.hidden) : null,
      [Icon(isDark ? 'moon' : 'sun')],
    );
  }

  @css
  static final List<StyleRule> styles = [
    css('.theme-toggle', [
      css('&')
        .box(
          radius: BorderRadius.circular(8.px),
          border: Border.unset, outline: Outline.unset, padding: EdgeInsets.all(.7.rem))
        .flexbox(alignItems: AlignItems.center)
        .background(color: Colors.transparent),
        css('&:hover').background(color: Colors.whiteSmoke),
    ]),
  ];
}
