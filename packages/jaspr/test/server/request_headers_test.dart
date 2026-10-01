@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:test/test.dart';

/// Renders [app] with a binding over [headers] and returns the body.
Future<String> renderWith(Map<String, List<String>> headers, Component app) async {
  final binding = ServerAppBinding((url: '/', basePath: '/', headers: headers), loadFile: (_) async => null);
  binding.initializeOptions(ServerOptions());
  binding.attachRootComponent(app);
  return utf8.decode(await binding.render(standalone: true)).trim();
}

/// Builds [read] with the current [BuildContext] and renders its result as text.
Component reading(String Function(BuildContext context) read) => Builder(builder: (context) => text(read(context)));

void main() {
  group('a binding over a header map', () {
    const headers = {
      'Accept': ['text/html', 'application/json'],
      'X-Custom': ['one'],
      'Cookie': ['a=1; b=2'],
    };

    test('joins repeated values in context.headers.', () async {
      expect(await renderWith(headers, reading((c) => c.headers['accept']!)), 'text/html,application/json');
    });

    test('looks up context.headers case-insensitively.', () async {
      expect(await renderWith(headers, reading((c) => c.headers['x-CUSTOM']!)), 'one');
    });

    test('lists every value in context.headersAll.', () async {
      expect(
        await renderWith(headers, reading((c) => c.headersAll['accept']!.join('|'))),
        'text/html|application/json',
      );
    });

    test('parses context.cookies from the cookie header.', () async {
      expect(await renderWith(headers, reading((c) => c.cookies.entries.join(','))), 'MapEntry(a: 1),MapEntry(b: 2)');
    });

    test('has no cookies without a cookie header.', () async {
      expect(await renderWith(const {}, reading((c) => '${c.cookies.length}')), '0');
    });
  });

  group('a shelf request', () {
    test('reaches context.headers through renderComponent.', () async {
      Jaspr.initializeApp();
      final request = Request('GET', Uri.parse('http://localhost/'), headers: {'X-Custom': 'shelf'});
      final result = await renderComponent(reading((c) => c.headers['x-custom']!), request: request, standalone: true);
      expect(utf8.decode(result.body).trim(), 'shelf');
    });

    test('reaches context.headers, when rendering in an isolate.', () async {
      Jaspr.initializeApp(useIsolates: true);
      addTearDown(Jaspr.initializeApp);
      final request = Request('GET', Uri.parse('http://localhost/'), headers: {'X-Custom': 'isolate'});
      final result = await renderComponent(reading((c) => c.headers['x-custom']!), request: request, standalone: true);
      expect(utf8.decode(result.body).trim(), 'isolate');
    });
  });
}
