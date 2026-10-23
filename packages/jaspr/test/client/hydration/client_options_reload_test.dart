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

  test('keeps loaded state across invalidation only for the same loader', () async {
    Future<void> loadFirst() async {}
    Future<void> loadSecond() async {}
    var loader = loadFirst;
    Jaspr.initializeApp(
      options: ClientOptions(
        clients: () => {'counter': ClientLoader((_) => const _Counter('counter', 'Initial'), loader: loader)},
      ),
    );

    expect(Jaspr.clients['counter']!.loadedBuilder, isA<Future<Object?>>());
    await Jaspr.clients['counter']!.loadedBuilder;

    Jaspr.invalidateClients();
    expect(Jaspr.clients['counter']!.loadedBuilder, isNot(isA<Future<Object?>>()));

    // Names can move to another library, which then still needs to load.
    loader = loadSecond;
    Jaspr.invalidateClients();
    expect(Jaspr.clients['counter']!.loadedBuilder, isA<Future<Object?>>());
  });

  testClient('keeps parent state when a reload adds a deferred client in its server child', (tester) async {
    final marker = DomValidator.clientMarkerPrefix;
    web.HTMLElement shellBody({required bool withChild}) {
      final child = withChild ? '<!--${marker}added--><button id="added">Server</button><!--/${marker}added-->' : '';
      final html =
          '<!--${marker}shell data={"child":"s${marker}1"}-->'
          '<div><button id="shell">Server</button>'
          '<!--s${marker}1--><div>$child</div><!--/s${marker}1--></div>'
          '<!--/${marker}shell-->';
      return web.DOMParser().parseFromString('<body>$html</body>'.toJS, 'text/html').body!;
    }

    Future<void> loadAdded() => Future<void>.delayed(Duration.zero);
    var hasAdded = false;
    web.document.body!.replaceWith(shellBody(withChild: false));
    Jaspr.initializeApp(
      options: ClientOptions(
        clients: () => {
          'shell': ClientLoader((params) => _Shell(child: params.mount(params.get<String>('child')))),
          if (hasAdded) 'added': ClientLoader((_) => const _Counter('added', 'Added'), loader: loadAdded),
        },
      ),
    );
    tester.pumpComponent(const ClientApp());
    await pumpEventQueue();
    await _click('shell', 'Shell: 1');

    hasAdded = true;
    Jaspr.invalidateClients();
    await _reload(tester, shellBody(withChild: true));

    expect(_button('shell').textContent, 'Shell: 1');
    await _click('added', 'Added: 1');
  });

  for (final hasExistingClient in [false, true]) {
    testClient('reloads new client registrations with existing client: $hasExistingClient', (tester) async {
      var version = 0;
      var initializations = 0;
      final loaded = <String>[];
      // Stand in for the generated `loadLibrary` tear-offs, which are the same for each client.
      final loaders = <String, Future<void> Function()>{};

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
            loader: loaders.putIfAbsent(
              id,
              () => () async {
                await Future<void>.delayed(Duration.zero);
                loaded.add(id);
              },
            ),
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
      // Reloads load only new clients, so existing ones resolve synchronously and keep their state.
      expect(loaded, [if (hasExistingClient) 'existing', 'added']);
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

class _Shell extends StatefulComponent {
  const _Shell({required this.child});

  final Component child;

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int count = 0;

  @override
  Component build(BuildContext context) => div([
    button(id: 'shell', onClick: () => setState(() => count++), [.text('Shell: $count')]),
    component.child,
  ]);
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
