import 'package:jaspr_builder/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('utils', () {
    test('compresses paths correctly', () {
      final paths = [
        'app.dart',
        'counter.dart',
        'counter.state.dart',
        'components/counter.dart',
        'components/other/home.dart',
        'components/pages/contact.dart',
        'components/pages/about.dart',
        'constants/theme.dart',
        'pages/about.dart',
        'pages/home.dart',
      ];

      final compressed = compressPaths(paths);

      expect(compressed, {
        'app.dart': 'app',
        'counter.dart': 'counter',
        'counter.state.dart': 'counter.state',
        'components/counter.dart': 'components/counter',
        'components/other/home.dart': 'other/home',
        'components/pages/contact.dart': 'contact',
        'components/pages/about.dart': 'pages/about',
        'constants/theme.dart': 'theme',
        'pages/about.dart': 'about',
        'pages/home.dart': 'home',
      });
    });

    test('writes imports with unique prefixes', () {
      final source =
          ''
          'import \'package:jaspr/jaspr.dart\';\n'
          '[[/]]\n'
          '\n'
          'var a = [[package:example/components/counter.dart]].Counter();\n'
          'var c = [[package:example/components/counter.state.dart]].Counter();\n'
          'var b = [[package:example/components/other/home.dart]].Home();\n'
          'var d = [[package:example/constants/theme.dart]].theme;\n'
          'var e = [[package:example/pages/about.dart]].About();\n'
          'var f = [[package:example/pages/home.dart]].Home();\n'
          'var g = [[package:other/home.dart]].Home();\n'
          'var h = [[package:other/pages/home.dart]].Home();\n'
          'var i = [[example/pages/about.dart]].About();\n'
          'var j = [[other/pages/about.dart]].About();\n'
          '';

      final result = ImportsWriter().resolve(source);
      expect(
        result,
        ''
        'import \'package:jaspr/jaspr.dart\';\n'
        'import \'example/pages/about.dart\' as _about;\n'
        'import \'other/pages/about.dart\' as _pages_about;\n'
        'import \'package:example/components/other/home.dart\' as _other_home;\n'
        'import \'package:example/components/counter.dart\' as _counter;\n'
        'import \'package:example/components/counter.state.dart\' as _counter\$state;\n'
        'import \'package:example/constants/theme.dart\' as _theme;\n'
        'import \'package:example/pages/about.dart\' as _\$example_pages_about;\n'
        'import \'package:example/pages/home.dart\' as _pages_home;\n'
        'import \'package:other/pages/home.dart\' as _\$other_pages_home;\n'
        'import \'package:other/home.dart\' as _home;\n'
        '\n'
        'var a = _counter.Counter();\n'
        'var c = _counter\$state.Counter();\n'
        'var b = _other_home.Home();\n'
        'var d = _theme.theme;\n'
        'var e = _\$example_pages_about.About();\n'
        'var f = _pages_home.Home();\n'
        'var g = _home.Home();\n'
        'var h = _\$other_pages_home.Home();\n'
        'var i = _about.About();\n'
        'var j = _pages_about.About();\n'
        '',
      );
    });
  });
}
