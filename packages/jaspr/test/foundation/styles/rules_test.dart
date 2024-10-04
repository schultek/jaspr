@TestOn('vm')

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style rules', () {
    test('block', () {
      expect(
        StyleRule(selector: Selector('.main'), styles: Styles.box(width: 100.px)).toCss(),
        equals('.main {\n'
            '  width: 100px;\n'
            '}'),
      );
      expect(
        css('.main').box(width: 100.px).toCss(),
        equals('.main {\n'
            '  width: 100px;\n'
            '}'),
      );
    });

    test('media', () {
      expect(
        StyleRule.media(query: MediaQuery.screen(minWidth: 1000.px), styles: [
          StyleRule(selector: Selector('.main'), styles: Styles.box(width: 100.px)),
        ]).toCss(),
        equals('@media screen and (min-width: 1000px) {\n'
            '  .main {\n'
            '    width: 100px;\n'
            '  }\n'
            '}'),
      );
      expect(
        css.media(MediaQuery.screen(minWidth: 1000.px), [css('.main').box(width: 100.px)]).toCss(),
        equals('@media screen and (min-width: 1000px) {\n'
            '  .main {\n'
            '    width: 100px;\n'
            '  }\n'
            '}'),
      );

      expect(
        css.media(MediaQuery.not(MediaQuery.screen(minWidth: 1000.px)), [css('.main').box(width: 100.px)]).toCss(),
        equals('@media not screen and (min-width: 1000px) {\n'
            '  .main {\n'
            '    width: 100px;\n'
            '  }\n'
            '}'),
      );

      expect(
        css.media(MediaQuery.any([MediaQuery.screen(minWidth: 1000.px), MediaQuery.print(maxWidth: 800.px)]),
            [css('.main').box(width: 100.px)]).toCss(),
        equals('@media screen and (min-width: 1000px), print and (max-width: 800px) {\n'
            '  .main {\n'
            '    width: 100px;\n'
            '  }\n'
            '}'),
      );
    });

    test('font', () {
      expect(
        StyleRule.fontFace(family: 'Roboto', style: FontStyle.italic, url: 'Roboto.ttf').toCss(),
        equals('@font-face {\n'
            '  font-family: "Roboto";\n'
            '  font-style: italic;\n'
            '  src: url(Roboto.ttf);\n'
            '}'),
      );
      expect(
        css.fontFace(family: 'Roboto', style: FontStyle.italic, url: 'Roboto.ttf').toCss(),
        equals('@font-face {\n'
            '  font-family: "Roboto";\n'
            '  font-style: italic;\n'
            '  src: url(Roboto.ttf);\n'
            '}'),
      );
    });

    test('layer', () {
      expect(
        StyleRule.layer(styles: [css('.main').box(width: 100.px)]).toCss(),
        equals('@layer {\n'
            '  .main {\n'
            '    width: 100px;\n'
            '  }\n'
            '}'),
      );
      expect(
        StyleRule.layer(name: 'base', styles: [css('.main').box(width: 100.px)]).toCss(),
        equals('@layer base {\n'
            '  .main {\n'
            '    width: 100px;\n'
            '  }\n'
            '}'),
      );
    });

    test('supports', () {
      expect(
        StyleRule.supports(condition: '(display: grid)', styles: [css('.main').box(width: 100.px)]).toCss(),
        equals('@supports (display: grid) {\n'
            '  .main {\n'
            '    width: 100px;\n'
            '  }\n'
            '}'),
      );
    });

    test('keyframes', () {
      expect(
        StyleRule.keyframes(name: 'fade', styles: {'from': Styles.box(opacity: 0), 'to': Styles.box(opacity: 1)})
            .toCss(),
        equals('@keyframes fade {\n'
            '  from {\n'
            '    opacity: 0.0;\n'
            '  }\n'
            '  to {\n'
            '    opacity: 1.0;\n'
            '  }\n'
            '}'),
      );
    });

    test('render to css', () {
      expect(
        [
          css('.main', [
            css('&').box(width: 100.px),
            css('p').text(fontSize: 2.em),
          ]),
          css.import('fonts.css'),
        ].render(),
        equals('@import url(fonts.css);\n'
            '.main {\n'
            '  width: 100px;\n'
            '}\n'
            '.main p {\n'
            '  font-size: 2em;\n'
            '}'),
      );
    });
  });
}
