@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:jaspr/client.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/src/dom/validator.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart' as web;

void main() {
  test('supports options without client registrations', () {
    final options = ClientOptions();
    Jaspr.initializeApp(options: options);

    expect(Jaspr.options, same(options));
    expect(Jaspr.clients, isEmpty);
  });

  test('clears cached registrations when initialized again', () {
    Jaspr.initializeApp(
      options: ClientOptions(clients: () => {'counter': ClientLoader((_) => const _Counter('counter', 'Initial'))}),
    );
    expect(Jaspr.clients, contains('counter'));

    Jaspr.initializeApp();

    expect(Jaspr.clients, isEmpty);
  });

  for (final hasExistingClient in [false, true]) {
    testClient('reloads new client registrations with existing client: $hasExistingClient', (tester) async {
      var version = 0;
      var initializations = 0;
      final loaded = <String>[];

      final options = ClientOptions(
        initialize: () => initializations++,
        // Stands in for the generated top-level `_$clients` function,
        // whose body hot reload replaces with the current registrations.
        clients: () {
          // Capture each generated factory's version, so retaining old loaders
          // cannot pass the test by observing a changed variable.
          final label = 'Version $version';
          ClientLoader loader(String id) => ClientLoader(
            (_) => _Counter(id, label),
            loader: () async {
              await Future<void>.delayed(Duration.zero);
              loaded.add(id);
            },
          );
          return {
            if (hasExistingClient) 'existing': loader('existing'),
            if (version == 1) 'added': loader('added'),
            if (hasExistingClient) 'unused': loader('unused'),
          };
        },
      );

      web.document.body!.replaceWith(_body(hasExistingClient: hasExistingClient, hasAddedClient: false));
      Jaspr.initializeApp(options: options);
      expect(Jaspr.clients.keys, hasExistingClient ? ['existing', 'unused'] : isEmpty);
      tester.pumpComponent(const ClientApp());
      await pumpEventQueue();

      if (hasExistingClient) {
        await _click('existing', 'Version 0: 1');
      }

      version = 1;
      expect(Jaspr.clients, isNot(contains('added')));
      Jaspr.invalidateClients();
      expect(loaded, isNot(contains('added')), reason: 'New deferred components should still load on demand.');

      await _reload(tester, _body(hasExistingClient: hasExistingClient, hasAddedClient: true));

      if (hasExistingClient) {
        expect(_button('existing').textContent, 'Version 1: 1');
        await _click('existing', 'Version 1: 2');
      }
      await _click('added', 'Version 1: 1');

      // A later reload also removes obsolete registrations and preserves state.
      version = 2;
      Jaspr.invalidateClients();
      expect(Jaspr.clients, isNot(contains('added')));
      await _reload(tester, _body(hasExistingClient: hasExistingClient, hasAddedClient: false));
      if (hasExistingClient) {
        await _click('existing', 'Version 2: 3');
      }
      expect(loaded, [
        if (hasExistingClient) ...['existing', 'existing'],
        'added',
        if (hasExistingClient) 'existing',
      ]);
      expect(Jaspr.options, same(options));
      expect(initializations, 1);
    });
  }
}

web.HTMLElement _body({required bool hasExistingClient, required bool hasAddedClient}) {
  final marker = DomValidator.clientMarkerPrefix;
  final html = [
    for (final id in [if (hasExistingClient) 'existing', if (hasAddedClient) 'added'])
      '<!--$marker$id--><button id="$id">Server</button><!--/$marker$id-->',
  ].join();
  return web.DOMParser().parseFromString('<body>$html</body>'.toJS, 'text/html').body!;
}

Future<void> _reload(ClientTester tester, web.HTMLElement body) async {
  await tester.binding.reloadBody(body);
  await pumpEventQueue();
}

web.HTMLButtonElement _button(String id) => web.document.getElementById(id)! as web.HTMLButtonElement;

Future<void> _click(String id, String text) async {
  _button(id).click();
  await pumpEventQueue();
  expect(_button(id).textContent, text);
}

class _Counter extends StatefulComponent {
  const _Counter(this.id, this.label);

  final String id;
  final String label;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int count = 0;

  @override
  Component build(BuildContext context) => button(
    id: component.id,
    onClick: () => setState(() => count++),
    [.text('${component.label}: $count')],
  );
}
