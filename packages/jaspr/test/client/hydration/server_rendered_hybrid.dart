import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:stream_channel/stream_channel.dart';

import 'server_rendered_app.dart';

// Called on the VM by the browser test, so the HTML exercises the real
// server child lists, boundary adapters, sync markers, and document normalization.
Future<void> hybridMain(StreamChannel<Object?> channel) async {
  Jaspr.initializeApp(
    options: ServerOptions(
      clientId: 'test.clients.dart.js',
      clients: {
        HydrationShell: ClientTarget<HydrationShell>('shell', params: (app) => {'child': app.child}),
        HydrationCounter: ClientTarget<HydrationCounter>('counter', params: (app) => {'id': app.id, 'seed': app.seed}),
      },
    ),
  );

  Component app(List<int> ids, int seed, int nestedSeed) => .fragment([
    p(id: 'before', [.text('Before')]),
    HydrationShell(
      child: ul([
        for (var id = 100; id < 103; id++) li([HydrationCounter(id: id, seed: nestedSeed)]),
      ]),
    ),
    ul(id: 'counters', [
      for (final id in ids) li(key: ValueKey(id), [HydrationCounter(id: id, seed: seed, key: ValueKey(id))]),
    ]),
    p(id: 'after', [.text('After')]),
  ]);

  // `X-Jaspr-Reload` makes the server respond with only the body, like a real client reload.
  Future<String> render(List<int> ids, int seed, {int nestedSeed = 10, bool reload = false}) async {
    final response = await renderComponent(
      app(ids, seed, nestedSeed),
      request: Request(
        'GET',
        Uri.http('localhost', '/'),
        headers: {if (reload) 'X-Jaspr-Reload': 'true'},
      ),
    );
    return utf8.decode(response.body);
  }

  final reloadedIds = [0, for (var id = 63; id > 0; id--) id, 64];
  channel.sink.add([
    await render([for (var id = 0; id < 64; id++) id], 10),
    await render(reloadedIds, 100, reload: true),
    // Change nested server state independently for its reload regression test.
    await render(reloadedIds, 100, nestedSeed: 100, reload: true),
  ]);
}
