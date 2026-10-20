import 'package:jaspr/dom.dart';
import 'package:jaspr_content/theme.dart';
import 'package:test/test.dart';

void main() {
  group('ContentTypography scoping', () {
    test('scopes simple block rule', () {
      expect(
        scopeRule(css('p').styles(color: Colors.red)).toCss(),
        equals(
          ':where(p):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '  color: red;\n'
          '}',
        ),
      );
    });

    test('scopes nested child rule with not-content', () {
      expect(
        scopeRule(
          css('div', [
            css('p').styles(color: Colors.red),
          ]),
        ).toCss(),
        equals(
          ':where(div):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '  :where(p):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '    color: red;\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('scopes deeply nested rules recursively', () {
      expect(
        scopeRule(
          css('div', [
            css('article', [
              css('p').styles(color: Colors.red),
            ]),
          ]),
        ).toCss(),
        equals(
          ':where(div):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '  :where(article):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '    :where(p):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '      color: red;\n'
          '    }\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('scopes multiple sibling child rules', () {
      expect(
        scopeRule(
          css('div', [
            css('h1').styles(color: Colors.black),
            css('p').styles(color: Colors.red),
          ]),
        ).toCss(),
        equals(
          ':where(div):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '  :where(h1):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '    color: black;\n'
          '  }\n'
          '  :where(p):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '    color: red;\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('scopes nested rule with own styles and children', () {
      expect(
        scopeRule(
          css('div', [
            css('p').styles(color: Colors.red),
          ]).styles(color: Colors.blue),
        ).toCss(),
        equals(
          ':where(div):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '  color: blue;\n'
          '  :where(p):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '    color: red;\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('preserves & selector for parent block styles without re-scoping', () {
      expect(
        scopeRule(
          css('p', [
            css('&').styles(color: Colors.blue),
            css('span').styles(color: Colors.red),
          ]),
        ).toCss(),
        equals(
          ':where(p):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '  color: blue;\n'
          '  :where(span):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '    color: red;\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('scopes pseudo-class with & in nested child', () {
      expect(
        scopeRule(
          css('a', [
            css('&:hover').styles(color: Colors.blue),
          ]),
        ).toCss(),
        equals(
          ':where(a):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '  :where(&:hover):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '    color: blue;\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('scopes comma-separated selector lists', () {
      expect(
        scopeRule(
          css('h1, h2', [
            css('span').styles(color: Colors.red),
          ]),
        ).toCss(),
        equals(
          ':where(h1, h2):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '  :where(span):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '    color: red;\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('recurses into @media rules with nested children', () {
      expect(
        scopeRule(
          css.media(MediaQuery.screen(), [
            css('div', [
              css('p').styles(color: Colors.red),
            ]),
          ]),
        ).toCss(),
        equals(
          '@media screen {\n'
          '  :where(div):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '    :where(p):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '      color: red;\n'
          '    }\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('recurses into @supports rules with nested children', () {
      expect(
        scopeRule(
          css.supports('(display: grid)', [
            css('div', [
              css('p').styles(color: Colors.red),
            ]),
          ]),
        ).toCss(),
        equals(
          '@supports (display: grid) {\n'
          '  :where(div):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '    :where(p):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '      color: red;\n'
          '    }\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('recurses into @layer rules with nested children', () {
      expect(
        scopeRule(
          css.layer([
            css('div', [
              css('p').styles(color: Colors.red),
            ]),
          ], name: 'components'),
        ).toCss(),
        equals(
          '@layer components {\n'
          '  :where(div):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '    :where(p):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '      color: red;\n'
          '    }\n'
          '  }\n'
          '}',
        ),
      );
    });

    test('scopes multiple rules via scopeContent', () {
      expect(
        scopeContent([
          css('div', [
            css('p').styles(color: Colors.red),
          ]),
          css('span').styles(color: Colors.blue),
        ]).map((rule) => rule.toCss()).join('\n'),
        equals(
          ':where(div):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '  :where(p):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '    color: red;\n'
          '  }\n'
          '}\n'
          ':where(span):not(:where([class~=not-content],[class~=not-content] *)) {\n'
          '  color: blue;\n'
          '}',
        ),
      );
    });
  });
}
