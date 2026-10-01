@TestOn('vm')
library;

import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:test/test.dart';

/// Renders the request's url, base path and a header as text.
Component describeRequest() =>
    Builder(builder: (context) => text('${context.url} ${context.binding.basePath} ${context.headers['x-custom']}'));

/// A request for the root of an app mounted at the root, without headers.
const RequestLike root = (url: '/', basePath: '/', headers: {});

// Jaspr.initializeApp() is never called in this file, so every render here
// relies on the options passed to it.
void main() {
  group('renderRequest', () {
    test('renders the url, base path and headers of the request it is given.', () async {
      final result = await renderRequest(
        describeRequest(),
        (
          url: '/page?q=1',
          basePath: '/admin/',
          headers: {
            'X-Custom': ['value'],
          },
        ),
        options: const ServerOptions(),
        standalone: true,
      );

      expect(result.statusCode, equals(200));
      expect(utf8.decode(result.body).trim(), equals('/page?q=1 /admin/ value'));
    });

    test('uses the options of each call without initializing Jaspr.', () async {
      Future<String> renderAs(String name) async {
        final result = await renderRequest(
          const _Marked(),
          root,
          options: ServerOptions(clientId: '$name.client.dart.js', clients: {_Marked: ClientTarget<_Marked>(name)}),
          standalone: true,
        );
        return utf8.decode(result.body);
      }

      expect(await renderAs('first'), contains('<!--@first-->'));
      expect(await renderAs('second'), contains('<!--@second-->'));
      expect(Jaspr.isInitialized, isFalse);
    });

    test('passes template files through loadFile.', () async {
      final result = await renderRequest(
        Document.template(name: 'index', child: text('app')),
        root,
        loadFile: (name) async => name == 'index.template.html'
            ? '<html><head><title>from template</title></head><body></body></html>'
            : null,
        options: const ServerOptions(),
      );

      expect(utf8.decode(result.body), contains('<title>from template</title>'));
    });
  });
}

class _Marked extends StatelessComponent {
  const _Marked();

  @override
  Component build(BuildContext context) => text('marked');
}
