import 'package:jaspr_builder/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('utils', () {
    test('compresses paths correctly', () {
      var paths = [
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

      var compressed = compressPaths(paths);

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
      var source =
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
          '';

      var result = ImportsWriter().resolve(source);
      expect(
        result,
        ''
        'import \'package:jaspr/jaspr.dart\';\n'
        'import \'package:example/components/other/home.dart\' as \$other_home;\n'
        'import \'package:example/components/counter.dart\' as \$counter;\n'
        'import \'package:example/components/counter.state.dart\' as \$counter\$state;\n'
        'import \'package:example/constants/theme.dart\' as \$theme;\n'
        'import \'package:example/pages/about.dart\' as \$about;\n'
        'import \'package:example/pages/home.dart\' as \$home;\n'
        '\n'
        'var a = \$counter.Counter();\n'
        'var c = \$counter\$state.Counter();\n'
        'var b = \$other_home.Home();\n'
        'var d = \$theme.theme;\n'
        'var e = \$about.About();\n'
        'var f = \$home.Home();\n'
        '',
      );
    });
  });
}
