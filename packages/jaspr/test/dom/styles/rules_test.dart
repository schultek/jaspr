@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/src/dom/styles/rules.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style rules', () {
    test('block', () {
      expect(
        StyleRule(
          selector: Selector('.main'),
          styles: Styles(width: 100.px),
        ).toCss(),
        equals(
          '.main {\n'
          '  width: 100px;\n'
          '}',
        ),
      );
      expect(
        css('.main').styles(width: 100.px).toCss(),
        equals(
          '.main {\n'
          '  width: 100px;\n'
          '}',
        ),
      );
    });

    test('media', () {
      expect(
        StyleRule.media(
          query: MediaQuery.screen(minWidth: 1000.px),
          styles: [
            StyleRule(
              selector: Selector('.main'),
              styles: Styles(width: 100.px),
            ),
          ],
        ).toCss(),
        equals(
          '@media screen and (min-width: 1000px) {\n'
          '  .main {\n'
          '    width: 100px;\n'
          '  }\n'
          '}',
        ),
      );
      expect(
        css.media(MediaQuery.screen(minWidth: 1000.px), [css('.main').styles(width: 100.px)]).toCss(),
        equals(
          '@media screen and (min-width: 1000px) {\n'
          '  .main {\n'
          '    width: 100px;\n'
          '  }\n'
          '}',
        ),
      );

      expect(
        css.media(
          MediaQuery.all(
            orientation: Orientation.landscape,
            prefersColorScheme: ColorScheme.dark,
            prefersContrast: Contrast.more,
          ),
          [css('.main').styles(width: 100.px)],
        ).toCss(),
        equals(
          '@media all and (orientation: landscape) and (prefers-color-scheme: dark) and (prefers-contrast: more) {\n'
          '  .main {\n'
          '    width: 100px;\n'
          '  }\n'
          '}',
        ),
      );

      expect(
        css.media(MediaQuery.not(MediaQuery.screen(minWidth: 1000.px)), [css('.main').styles(width: 100.px)]).toCss(),
        equals(
          '@media not screen and (min-width: 1000px) {\n'
          '  .main {\n'
          '    width: 100px;\n'
          '  }\n'
          '}',
        ),
      );

      expect(
        css.media(MediaQuery.any([MediaQuery.screen(minWidth: 1000.px), MediaQuery.print(maxWidth: 800.px)]), [
          css('.main').styles(width: 100.px),
        ]).toCss(),
        equals(
          '@media screen and (min-width: 1000px), print and (max-width: 800px) {\n'
          '  .main {\n'
          '    width: 100px;\n'
          '  }\n'
          '}',
        ),
      );

      expect(
        css.media(MediaQuery.raw('not all and (hover: hover)'), [css('.main').styles(width: 100.px)]).toCss(),
        equals(
          '@media not all and (hover: hover) {\n'
          '  .main {\n'
          '    width: 100px;\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('font', () {
      expect(
        StyleRule.fontFace(family: 'Roboto', style: FontStyle.italic, url: 'Roboto.ttf').toCss(),
        equals(
          '@font-face {\n'
          '  font-family: "Roboto";\n'
          '  font-style: italic;\n'
          '  src: url(Roboto.ttf);\n'
          '}',
        ),
      );
      expect(
        css.fontFace(family: 'Roboto', style: FontStyle.italic, url: 'Roboto.ttf').toCss(),
        equals(
          '@font-face {\n'
          '  font-family: "Roboto";\n'
          '  font-style: italic;\n'
          '  src: url(Roboto.ttf);\n'
          '}',
        ),
      );
    });

    test('layer', () {
      expect(
        StyleRule.layer(styles: [css('.main').styles(width: 100.px)]).toCss(),
        equals(
          '@layer {\n'
          '  .main {\n'
          '    width: 100px;\n'
          '  }\n'
          '}',
        ),
      );
      expect(
        StyleRule.layer(
          name: 'base',
          styles: [css('.main').styles(width: 100.px)],
        ).toCss(),
        equals(
          '@layer base {\n'
          '  .main {\n'
          '    width: 100px;\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('supports', () {
      expect(
        StyleRule.supports(
          condition: '(display: grid)',
          styles: [css('.main').styles(width: 100.px)],
        ).toCss(),
        equals(
          '@supports (display: grid) {\n'
          '  .main {\n'
          '    width: 100px;\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('keyframes', () {
      expect(
        StyleRule.keyframes(name: 'fade', styles: {'from': Styles(opacity: 0), 'to': Styles(opacity: 1)}).toCss(),
        equals(
          '@keyframes fade {\n'
          '  from {\n'
          '    opacity: 0.0;\n'
          '  }\n'
          '  to {\n'
          '    opacity: 1.0;\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('render to css', () {
      expect(
        [
          css('.main', [css('&').styles(width: 100.px), css('p').styles(fontSize: 2.em)]),
          css.import('fonts.css'),
        ].render(),
        equals(
          '@import url(fonts.css);\n'
          '.main {\n'
          '  width: 100px;\n'
          '  p {\n'
          '    font-size: 2em;\n'
          '  }\n'
          '}',
        ),
      );
    });
  });

  group('nested style rules', () {
    test('a nested selector stays nested', () {
      expect(
        css('.main', [css('&:hover').styles(color: Colors.blue)]).toCss(),
        equals(
          '.main {\n'
          '  &:hover {\n'
          '    color: blue;\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('a child whose selector is just & belongs to the parent block', () {
      expect(
        css('.main', [css('&').styles(width: 100.px)]).toCss(),
        equals(
          '.main {\n'
          '  width: 100px;\n'
          '}',
        ),
      );
    });

    test('nests as deep as it is declared', () {
      expect(
        css('.main', [
          css('ul', [
            css('li', [css('&:first-child').styles(fontWeight: FontWeight.bold)]),
          ]),
        ]).toCss(),
        equals(
          '.main {\n'
          '  ul {\n'
          '    li {\n'
          '      &:first-child {\n'
          '        font-weight: bold;\n'
          '      }\n'
          '    }\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('an at-rule nested in a rule stays inside it', () {
      expect(
        css('.main', [
          css('&').styles(width: 100.px),
          css.media(MediaQuery.screen(minWidth: 1000.px), [css('&').styles(width: 200.px)]),
        ]).toCss(),
        equals(
          '.main {\n'
          '  width: 100px;\n'
          '  @media screen and (min-width: 1000px) {\n'
          '    width: 200px;\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('a bare & writes into any grouping at-rule nested in a rule', () {
      expect(
        css('.main', [
          css.supports('(display: grid)', [css('&').styles(display: Display.grid)]),
          css.layer(name: 'base', [css('&').styles(width: 100.px)]),
        ]).toCss(),
        equals(
          '.main {\n'
          '  @supports (display: grid) {\n'
          '    display: grid;\n'
          '  }\n'
          '  @layer base {\n'
          '    width: 100px;\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('a bare & writes into an at-rule nested in another one', () {
      expect(
        css('.main', [
          css.media(MediaQuery.screen(minWidth: 1000.px), [
            css.supports('(display: grid)', [css('&').styles(display: Display.grid)]),
          ]),
        ]).toCss(),
        equals(
          '.main {\n'
          '  @media screen and (min-width: 1000px) {\n'
          '    @supports (display: grid) {\n'
          '      display: grid;\n'
          '    }\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('any other selector in a nested at-rule stays a nested rule', () {
      expect(
        css('.main', [
          css.media(MediaQuery.screen(minWidth: 1000.px), [
            css('&').styles(width: 200.px),
            css('&:hover').styles(width: 300.px),
          ]),
        ]).toCss(),
        equals(
          '.main {\n'
          '  @media screen and (min-width: 1000px) {\n'
          '    width: 200px;\n'
          '    &:hover {\n'
          '      width: 300px;\n'
          '    }\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('a rule with only children still opens its block', () {
      expect(
        css('.main', [css('p').styles(fontSize: 2.em)]).toCss(),
        equals(
          '.main {\n'
          '  p {\n'
          '    font-size: 2em;\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('a rule with nothing in it renders nothing', () {
      expect(css('.main').toCss(), isEmpty);
      expect(css('.main', [css('p')]).toCss(), isEmpty);
    });
  });
}
