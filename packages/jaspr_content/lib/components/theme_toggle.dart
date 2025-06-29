import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import '_internal/icon.dart';

/// A theme toggle button.
@client
class ThemeToggle extends StatefulComponent {
  const ThemeToggle({super.key});

  @override
  State<ThemeToggle> createState() => _ThemeToggleState();

  @css
  static final List<StyleRule> styles = [
    css('.theme-toggle', [
      css('&').styles(
        display: Display.flex,
        padding: Padding.all(.7.rem),
        border: Border.unset,
        radius: BorderRadius.circular(8.px),
        outline: Outline.unset,
        alignItems: AlignItems.center,
        backgroundColor: Colors.transparent,
      ),
      css('&:hover').styles(
        backgroundColor: Color('color-mix(in srgb, currentColor 5%, transparent)'),
      ),
    ]),
  ];
}

class _ThemeToggleState extends State<ThemeToggle> {
  bool _isDark = false;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) return;
    _isDark = web.document.documentElement!.getAttribute('data-theme') == 'dark';
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (!kIsWeb) {
      yield Document.head(children: [
        // ignore: prefer_html_methods
        DomComponent(id: 'theme-script', tag: 'script', children: [
          raw('''
          let userTheme = window.localStorage.getItem('jaspr:theme');
          if (userTheme != null) {
            document.documentElement.setAttribute('data-theme', userTheme);
          } else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
            document.documentElement.setAttribute('data-theme', 'dark');
          } else {
            document.documentElement.setAttribute('data-theme', 'light');
          }
        ''')
        ]),
      ]);
    }

    if (kIsWeb) {
      yield Document.html(attributes: {'data-theme': _isDark ? 'dark' : 'light'});
    }

    yield button(
      classes: 'theme-toggle',
      attributes: {'aria-label': 'Theme Toggle'},
      onClick: () {
        setState(() {
          _isDark = !_isDark;
        });
        web.window.localStorage.setItem('jaspr:theme', _isDark ? 'dark' : 'light');
      },
      styles: !kIsWeb ? Styles(visibility: Visibility.hidden) : null,
      [
        span(styles: Styles(display: _isDark ? Display.none : null), [MoonIcon(size: 20)]),
        span(styles: Styles(display: _isDark ? null : Display.none), [SunIcon(size: 20)]),
      ],
    );
  }
}
