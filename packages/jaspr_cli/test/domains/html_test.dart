import 'package:jaspr_cli/src/domains/html_domain.dart';
import 'package:test/test.dart';

void main() {
  Future<String> convert(String html, {String? query}) => HtmlDomain.convertHtml(html, query);

  group('html domain', () {
    test('converts simple element with text', () async {
      final result = await convert('<div>Hello</div>');
      expect(
        result,
        equals(
          'div([\n'
          '  .text(\'Hello\'),\n'
          '])',
        ),
      );
    });

    test('converts nested elements', () async {
      final result = await convert('<ul><li>One</li><li>Two</li></ul>');
      expect(
        result,
        equals(
          'ul([\n'
          '  li([\n'
          '    .text(\'One\'),\n'
          '  ]),\n'
          '  li([\n'
          '    .text(\'Two\'),\n'
          '  ]),\n'
          '])',
        ),
      );
    });

    test('converts element with attributes, id and class', () async {
      final result = await convert('<p id="foo" class="bar" attr="value"></p>');
      expect(result, equals('p(id: \'foo\', classes: \'bar\', attributes: {\'attr\': \'value\'}, [])'));
    });

    test('converts element with multiline text', () async {
      final result = await convert('<div>Hello\nWorld</div>');
      expect(
        result,
        equals(
          'div([\n'
          '  .text(\'\'\'Hello\n'
          'World\'\'\'),\n'
          '])',
        ),
      );
    });

    test('converts element with special attribute (a href)', () async {
      final result = await convert('<a href="/foo">Link</a>');
      expect(
        result,
        equals(
          'a(href: \'/foo\', [\n'
          '  .text(\'Link\'),\n'
          '])',
        ),
      );
    });

    test('escapes quotes in text and attributes', () async {
      final result = await convert('<div title="He said \'Hello\'">She said \'Hi\'</div>');
      expect(
        result,
        equals(
          'div(attributes: {\'title\': \'He said \\\'Hello\\\'\'}, [\n'
          '  .text(\'She said \\\'Hi\\\'\'),\n'
          '])',
        ),
      );
    });

    test('converts content of script and style tags', () async {
      final result = await convert(
        '<div>Hello<style>.foo { color: red; }</style><script>alert("Hi")</script>World</div>',
      );
      expect(
        result,
        equals(
          'div([\n'
          '  .text(\'Hello\'),\n'
          '  Component.element(tag: \'style\', children: [\n'
          '    .text(\'.foo { color: red; }\')\n'
          '  ]),\n'
          '  script(content: \'alert("Hi")\'),\n'
          '  .text(\'World\'),\n'
          '])',
        ),
      );
    });

    test('converts full document', () async {
      final result = await convert('<!DOCTYPE html><html><head></head><body>Hello</body></html>');
      expect(result, equals('html([\n  head([]),\n  body([\n    .text(\'Hello\'),\n  ]),\n])'));
    });

    test('converts body', () async {
      final result = await convert('<body>Hello</body>');
      expect(result, equals('body([\n  .text(\'Hello\'),\n])'));
    });

    test('applies query to converted html', () async {
      final result = await convert('<div>Hello <p>World</p></div>', query: 'p');
      expect(result, equals('p([\n  .text(\'World\'),\n])'));
    });
  });
}
