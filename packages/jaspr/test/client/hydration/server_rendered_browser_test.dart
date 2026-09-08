/// Browser integration tests for hydration and reloads using real server output.
///
/// `server_rendered_hybrid.dart` renders shared test components in a VM isolate
/// and supplies initial HTML plus `X-Jaspr-Reload` responses.
/// This exercises server-generated client/server boundaries, sync markers, and
/// document normalization together with the browser's hydration and reload paths.
///
/// Checks DOM reuse, synchronized state, preservation or reset of local state
/// depending on keys and positions, and event handlers after hydration and reload.
@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:jaspr/client.dart';
import 'package:jaspr/src/client/utils.dart';
import 'package:jaspr/src/dom/validator.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart' as web;

import 'server_rendered_app.dart';

void main() {
  late List<String> html;

  // Render on the VM once and share the resulting markup across all tests.
  setUpAll(() async {
    final channel = spawnHybridUri('server_rendered_hybrid.dart');
    html = (await channel.stream.first as List<Object?>).cast<String>();
  });

  testClient('hydrates server-rendered ranges and reloads their state and events', (tester) async {
    final marker = DomValidator.clientMarkerPrefix;
    final initialBody = _parseBody(html[0]);
    final initialHtml = (initialBody.innerHTML as JSString).toDart;
    expect(initialHtml, contains('<!--${marker}shell'));
    expect(initialHtml, contains('<!--${marker}counter'));
    web.document.body!.replaceWith(initialBody);
    final initialButton = _button('counter-0');
    final counterKey = GlobalStateKey<HydrationCounterState>();
    final movingCounterKey = GlobalStateKey<HydrationCounterState>();

    await _hydrate(tester, keys: {0: counterKey, 1: movingCounterKey});

    expect(_button('counter-0'), same(initialButton));
    expect(initialButton.textContent, '0:10:0');
    final nestedButton = _button('counter-100');
    await _clickAndExpectText(nestedButton, '100:110:1');
    expect(_buttonIds(), List.generate(64, (i) => 'counter-$i'));
    // The reload below covers each combination of key type and position change:
    //
    // | Counter | Key    | Position on reload                          |
    // | ------- | ------ | ------------------------------------------- |
    // | 0       | global | stays first                                 |
    // | 1       | global | moves from second to second to last         |
    // | 2       | value  | moves from third to third to last           |
    // | 100     | value  | stays first in the nested server component  |
    //
    // Counter 0 is the control for counter 1: its state would survive through
    // its positional anchor even without a global key.
    final initialState = counterKey.currentState!;
    await _clickAndExpectText(initialButton, '0:10:1');

    final movingButton = _button('counter-1');
    final movingState = movingCounterKey.currentState!;
    movingButton.click();
    await _clickAndExpectText(movingButton, '1:11:2');

    final movingValueKeyedButton = _button('counter-2');
    await _clickAndExpectText(movingValueKeyedButton, '2:12:1');

    await _reload(tester, _parseBody(html[1]));

    expect(_buttonIds(), [
      'counter-0',
      for (var id = 63; id > 0; id--) 'counter-$id',
      'counter-64',
    ]);
    expect(web.document.querySelectorAll('#shell').length, 1);
    expect(web.document.getElementById('before')!.textContent, 'Before');
    expect(web.document.getElementById('after')!.textContent, 'After');
    expect(counterKey.currentState, same(initialState));
    final reloadedButton = _button('counter-0');
    expect(reloadedButton.textContent, '0:100:1');
    await _clickAndExpectText(reloadedButton, '0:100:2');
    expect(movingCounterKey.currentState, same(movingState));
    final movedButton = _button('counter-1');
    expect(movedButton.textContent, '1:101:2');
    await _clickAndExpectText(movedButton, '1:101:3');
    // The anchor key of a client boundary is its position in the document,
    // so a component that keeps its position keeps its state without needing a global key.
    //
    // TODO: Counter 100 is deliberately rendered with the same seed and
    // not clicked after the reload, as nested reloads currently
    // retain stale synced state and duplicate event handlers.
    // The skipped tests below cover both of those bugs,
    // so this assertion only verifies that its local click count survived.
    expect(_button('counter-100').textContent, '100:110:1');

    // Whereas one that moves is rebuilt against a different anchor,
    // and only the synced count is restored from the server markup.
    // Preserving the rest of its state across a move needs a global key,
    // as counter 1 above has.
    expect(_button('counter-2').textContent, '2:102:0');
    await _clickAndExpectText(_button('counter-2'), '2:102:1');
    expect(_button('counter-63').textContent, '63:163:0');
    await _clickAndExpectText(_button('counter-63'), '63:163:1');
    expect(_button('counter-64').textContent, '64:164:0');
    await _clickAndExpectText(_button('counter-64'), '64:164:1');
  });

  testClient(
    'reloads a nested counter without duplicating its click handler',
    (tester) async {
      web.document.body!.replaceWith(_parseBody(html[0]));
      await _hydrate(tester);
      await _clickAndExpectText(_button('counter-100'), '100:110:1');

      await _reload(tester, _parseBody(html[1]));

      expect(_button('counter-100').textContent, '100:110:1');
      await _clickAndExpectText(_button('counter-100'), '100:110:2');
    },
    // TODO: Enable when nested reloads stop retaining duplicate event handlers.
    // Currently the first click after reload increments the click count from 1 to 3.
    skip: true,
  );

  testClient(
    'reloads a nested counter with fresh synced state and preserves its local state',
    (tester) async {
      web.document.body!.replaceWith(_parseBody(html[0]));
      await _hydrate(tester);
      await _clickAndExpectText(_button('counter-100'), '100:110:1');

      final newBody = _parseBody(html[2]);
      expect(newBody.querySelector('#counter-100')!.textContent, '100:200:0');
      await _reload(tester, newBody);

      expect(_button('counter-100').textContent, '100:200:1');
    },
    // TODO: Enable when nested reloads apply the new server markup and synced state.
    // Currently counter 100 keeps its old synced count of 110 instead of receiving 200.
    skip: true,
  );
}

web.HTMLElement _parseBody(String html) => web.DOMParser().parseFromString(html.toJS, 'text/html').body!;

Future<void> _hydrate(ClientTester tester, {Map<int, Key> keys = const {}}) async {
  Jaspr.initializeApp(
    options: ClientOptions(
      clients: {
        'shell': ClientLoader((params) => HydrationShell(child: params.mount(params.get<String>('child')))),
        'counter': ClientLoader((params) {
          final id = params.get<int>('id');
          return HydrationCounter(id: id, seed: params.get<int>('seed'), key: keys[id] ?? ValueKey(id));
        }),
      },
    ),
  );
  tester.pumpComponent(const ClientApp());
  await pumpEventQueue(times: 1);
}

Future<void> _reload(ClientTester tester, web.HTMLElement newBody) async {
  // Use the same root replacement and performReload sequence as
  // the client's reload handler, with actual `X-Jaspr-Reload` server output.
  final root = tester.binding.rootElement!;
  (root.renderObject as RootDomRenderObject).setRootNode(newBody);
  root.owner.performReload(root);
  web.document.body!.replaceWith(newBody);
  await pumpEventQueue(times: 1);
}

web.HTMLButtonElement _button(String id) => web.document.getElementById(id)! as web.HTMLButtonElement;

Future<void> _clickAndExpectText(web.HTMLButtonElement button, String expected) async {
  button.click();
  await pumpEventQueue(times: 1);
  expect(button.textContent, expected);
}

List<String> _buttonIds() => [
  for (final button in web.document.querySelectorAll('#counters button').toIterable()) (button as web.Element).id,
];
