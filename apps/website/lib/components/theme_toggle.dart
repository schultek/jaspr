import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import '../constants/theme.dart';
import 'icon.dart';

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

    isDark = web.document.documentElement!.className == 'dark';
  }

  @override
  Component build(BuildContext context) {
    return .fragment([
      if (kIsWeb)
        Document.html(attributes: {'class': isDark ? 'dark' : 'light'})
      else
        Document.head(
          children: [
            // ignore: prefer_html_methods
            .element(
              id: 'theme-script',
              tag: 'script',
              children: [
                RawText('''
            let userTheme = window.localStorage.getItem('active-theme');
            if (userTheme != null) {
              document.documentElement.className = userTheme;
            } else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
              document.documentElement.className = 'dark';
            } else {
              document.documentElement.className = 'light';
            }
          '''),
              ],
            ),
          ],
        ),
      button(
        classes: 'theme-toggle',
        attributes: {'aria-label': 'Theme Toggle'},
        onClick: () {
          setState(() {
            isDark = !isDark;
          });
          web.window.localStorage.setItem('active-theme', isDark ? 'dark' : 'light');
        },
        styles: !kIsWeb ? Styles(visibility: .hidden) : null,
        [Icon(isDark ? 'moon' : 'sun')],
      ),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.theme-toggle', [
      css('&').styles(
        display: .flex,
        padding: .all(.7.rem),
        border: .unset,
        radius: .circular(8.px),
        outline: .unset,
        alignItems: .center,
        color: textBlack,
        backgroundColor: Colors.transparent,
      ),
      css('&:hover').styles(backgroundColor: hoverOverlayColor),
    ]),
  ];
}
