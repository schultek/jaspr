@TestOn('vm')
library;

import 'dart:convert';
import 'dart:typed_data';

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
        _decodedMatches(
          '<!DOCTYPE html>\n'
          '<html><head></head><body><div id="test"></div></body></html>\n'
          '',
        ),
      );
    });

    test('renders document component', () async {
      var result = await renderComponent(
        Document(
          lang: 'en',
          base: '/app',
          meta: {'keywords': 'test'},
          body: div(id: 'test', []),
        ),
      );

      expect(
        result.body,
        _decodedMatches(
          '<!DOCTYPE html>\n'
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
          '',
        ),
      );
    });

    test('renders standalone component', () async {
      var result = await renderComponent(div(id: 'test', []), standalone: true);

      expect(result.body, _decodedMatches('<div id="test"></div>\n'));
    });

    test('renders component with headers', () async {
      var result = await renderComponent(
        Builder(
          builder: (context) {
            var value = context.headers['x-test'];
            context.setHeader('x-test2', 'xyz');
            return div(id: 'test', [text(value ?? '')]);
          },
        ),
        request: Request('GET', Uri.parse('https://0.0.0.0/'), headers: {'x-test': 'abc'}),
        standalone: true,
      );

      expect(result.statusCode, equals(200));
      expect(result.body, _decodedMatches('<div id="test">abc</div>\n'));
      expect(
        result.headers,
        equals({
          'Content-Type': ['text/html'],
          'x-test2': ['xyz'],
        }),
      );
    });

    test('renders component with cookies', () async {
      var result = await renderComponent(
        Builder(
          builder: (context) {
            var value = context.cookies['test'];
            context.setCookie('test2', 'xyz');
            return div(id: 'test', [text(value ?? '')]);
          },
        ),
        request: Request('GET', Uri.parse('https://0.0.0.0/'), headers: {'cookie': 'test=abc'}),
        standalone: true,
      );

      expect(result.statusCode, equals(200));
      expect(result.body, _decodedMatches('<div id="test">abc</div>\n'));
      expect(
        result.headers,
        equals({
          'Content-Type': ['text/html'],
          'set-cookie': ['test2=xyz; HttpOnly'],
        }),
      );
    });

    test('renders custom text responses', () async {
      var result = await renderComponent(
        Builder(
          builder: (context) {
            var value = context.cookies['test'];
            context.setStatusCode(201, responseBody: 'custom');
            return div(id: 'test', [text(value ?? '')]);
          },
        ),
        request: Request('GET', Uri.parse('https://0.0.0.0/'), headers: {'cookie': 'test=abc'}),
        standalone: true,
      );

      expect(result.statusCode, equals(201));
      expect(result.body, _decodedMatches('custom'));
    });

    test('renders custom binary responses', () async {
      var result = await renderComponent(
        Builder(
          builder: (context) {
            var value = context.cookies['test'];
            context.setStatusCode(201, responseBody: Uint8List.fromList([1, 2, 3]));
            return div(id: 'test', [text(value ?? '')]);
          },
        ),
        request: Request('GET', Uri.parse('https://0.0.0.0/'), headers: {'cookie': 'test=abc'}),
        standalone: true,
      );

      expect(result.statusCode, equals(201));
      expect(result.body, equals([1, 2, 3]));
    });

    test('forbids rendering custom objects', () async {
      await renderComponent(
        Builder(
          builder: (context) {
            var value = context.cookies['test'];
            expect(() => context.setStatusCode(201, responseBody: DateTime.now()), throwsArgumentError);
            return div(id: 'test', [text(value ?? '')]);
          },
        ),
        request: Request('GET', Uri.parse('https://0.0.0.0/'), headers: {'cookie': 'test=abc'}),
        standalone: true,
      );
    });
  });
}

TypeMatcher<List<int>> _decodedMatches(dynamic string) {
  return isA<List<int>>().having((e) => utf8.decode(e), 'decoded', string);
}
