@TestOn('vm')
library;

import 'package:jaspr/server.dart';
import 'package:jaspr_test/server_test.dart';

void main() {
  group('render test', () {
    setUpAll(() {
      Jaspr.initializeApp(useIsolates: false);
    });

    test('renders component with document structure', () async {
      var result = await renderComponent(div(id: 'test', []));

      expect(
          result.body,
          equals('<!DOCTYPE html>\n'
              '<html><head></head><body><div id="test"></div></body></html>\n'
              ''));
    });

    test('renders document component', () async {
      var result = await renderComponent(
          Document(lang: 'en', base: '/app', meta: {'keywords': 'test'}, body: div(id: 'test', [])));

      expect(
          result.body,
          equals('<!DOCTYPE html>\n'
            '<html lang="en">\n'
            '  <head>\n'
            '    <base href="/app/"/>\n'
            '    <meta charset="utf-8"/>\n'
            '    <!--\$-->\n'
            '    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>\n'
            '    <meta name="keywords" content="test"/>\n'
            '    <!--/-->\n'
            '  </head>\n'
            '  <body><div id="test"></div></body>\n'
            '</html>\n'
            ''));
    });

    test('renders standalone component', () async {
      var result = await renderComponent(div(id: 'test', []), standalone: true);

      expect(result.body, equals('<div id="test"></div>\n'));
    });

    test('renders component with headers', () async {
      var result = await renderComponent(
        Builder(builder: (context) sync* {
          var value = context.headers['x-test'];
          context.setHeader('x-test2', 'xyz');
          yield div(id: 'test', [text(value ?? '')]);
        }),
        request: Request('GET', Uri.parse('https://0.0.0.0/'), headers: {'x-test': 'abc'}),
        standalone: true,
      );

      expect(result.statusCode, equals(200));
      expect(result.body, equals('<div id="test">abc</div>\n'));
      expect(
        result.headers,
        equals({
          'Content-Type': ['text/html'],
          'x-test2': ['xyz']
        }),
      );
    });

    test('renders component with cookies', () async {
      var result = await renderComponent(
        Builder(builder: (context) sync* {
          var value = context.cookies['test'];
          context.setCookie('test2', 'xyz');
          yield div(id: 'test', [text(value ?? '')]);
        }),
        request: Request('GET', Uri.parse('https://0.0.0.0/'), headers: {'cookie': 'test=abc'}),
        standalone: true,
      );

      expect(result.statusCode, equals(200));
      expect(result.body, equals('<div id="test">abc</div>\n'));
      expect(
        result.headers,
        equals({
          'Content-Type': ['text/html'],
          'set-cookie': ['test2=xyz; HttpOnly']
        }),
      );
    });
  });
}
