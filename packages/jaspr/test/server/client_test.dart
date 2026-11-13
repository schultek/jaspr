@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_test/server_test.dart';

class App1 extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div(attributes: {'data-app': '1'}, []);
  }
}

class App2 extends StatelessComponent {
  const App2({this.count, this.label});

  final int? count;
  final String? label;

  @override
  Component build(BuildContext context) {
    return div(attributes: {'data-app': '2'}, []);
  }
}

class App3 extends StatefulComponent {
  const App3();

  @override
  State<App3> createState() => _App3State();
}

class _App3State extends State<App3> with SyncStateMixin<App3, Map<String, Object?>> {
  int count = 3;

  @override
  Map<String, Object?> getState() {
    return {'count': count};
  }

  @override
  void updateState(Map<String, Object?> value) {
    count = value['count'] as int;
  }

  @override
  Component build(BuildContext context) {
    return div(attributes: {'data-app': '3'}, []);
  }
}

class App4 extends StatefulComponent {
  const App4();

  @override
  State<App4> createState() => _App4State();
}

class _App4State extends State<App4> with SyncStateMixin<App4, Map<String, Object?>>, PreloadStateMixin {
  String label = 'hello';

  @override
  Future<void> preloadState() async {
    await Future<void>.delayed(Duration(milliseconds: 10));
    label = 'world';
  }

  @override
  Map<String, Object?> getState() {
    return {'label': label};
  }

  @override
  void updateState(Map<String, Object?> value) {
    label = value['label'] as String;
  }

  @override
  Component build(BuildContext context) {
    return div(attributes: {'data-app': '4'}, []);
  }
}

class AppWithServerComponent extends StatelessComponent {
  const AppWithServerComponent({required this.child});

  final Component child;

  @override
  Component build(BuildContext context) {
    return div(attributes: {'data-app': 'with-child'}, [child]);
  }
}

class AppWithMultipleServerComponents extends StatelessComponent {
  const AppWithMultipleServerComponents({required this.child1, required this.child2});

  final Component child1;
  final Component child2;

  @override
  Component build(BuildContext context) {
    return div(attributes: {'data-app': 'with-multiple'}, [child1, child2]);
  }
}

class ModelWithComponent {
  const ModelWithComponent(this.child);

  final Component child;

  Map<String, dynamic> toRaw() => {'child': child};
}

class AppWithCustomModel extends StatelessComponent {
  const AppWithCustomModel({required this.model});

  final ModelWithComponent model;

  @override
  Component build(BuildContext context) {
    return div(attributes: {'data-app': 'with-model'}, [model.child]);
  }
}

void main() {
  group('@client', () {
    setUpAll(() {
      Jaspr.initializeApp(
        options: ServerOptions(
          clientId: 'main.clients.dart.js',
          clients: {
            App1: ClientTarget<App1>('app1'),
            App2: ClientTarget<App2>('app2', params: (app) => {'count': app.count, 'label': app.label}),
            App3: ClientTarget<App3>('app3'),
            App4: ClientTarget<App4>('app4'),
            AppWithServerComponent: ClientTarget<AppWithServerComponent>(
              'app_with_server_component',
              params: (app) => {'child': app.child},
            ),
            AppWithMultipleServerComponents: ClientTarget<AppWithMultipleServerComponents>(
              'app_with_multiple_server_components',
              params: (app) => {'child1': app.child1, 'child2': app.child2},
            ),
            AppWithCustomModel: ClientTarget<AppWithCustomModel>(
              'app_with_custom_model',
              params: (app) => {'model': app.model.toRaw()},
            ),
          },
        ),
      );
    });

    testServer('adds component markers and script', (tester) async {
      tester.pumpComponent(App1());

      final response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body><!--@app1--><div data-app="1"></div><!--/@app1--></body>\n'
          '</html>\n'
          '',
        ),
      );
    });

    testServer('adds parameters as data', (tester) async {
      tester.pumpComponent(App2(count: 1, label: 'Test'));

      final response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body><!--@app2 data<{"count":1,"label":"Test"}>--><div data-app="2"></div><!--/@app2--></body>\n'
          '</html>\n'
          '',
        ),
      );
    });

    testServer('adds sync marker inside of component marker', (tester) async {
      tester.pumpComponent(App3());

      final response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body><!--@app3--><!--\${"count":3}--><div data-app="3"></div><!--/@app3--></body>\n'
          '</html>\n'
          '',
        ),
      );
    });

    testServer('adds sync marker inside of component marker with preload state', (tester) async {
      tester.pumpComponent(App4());

      final response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body><!--@app4--><!--\${"label":"world"}--><div data-app="4"></div><!--/@app4--></body>\n'
          '</html>\n'
          '',
        ),
      );
    });

    testServer('renders server components inside client components', (tester) async {
      tester.pumpComponent(AppWithServerComponent(child: span([text('Hello')])));

      final response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body>\n'
          '    <!--@app_with_server_component data<{"child":"s@1"}>-->\n'
          '    <div data-app="with-child"><!--s@1--><span>Hello</span><!--/s@1--></div>\n'
          '    <!--/@app_with_server_component-->\n'
          '  </body>\n'
          '</html>\n'
          '',
        ),
      );
    });

    testServer('renders multiple identical server components with shared IDs', (tester) async {
      final serverChild = span([text('Hello')]);
      tester.pumpComponent(AppWithMultipleServerComponents(child1: serverChild, child2: serverChild));

      final response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body>\n'
          '    <!--@app_with_multiple_server_components data<{"child1":"s@1","child2":"s@1"}>-->\n'
          '    <div data-app="with-multiple"><!--s@1--><span>Hello</span><!--/s@1--><!--s@1--><span>Hello</span><!--/s@1--></div>\n'
          '    <!--/@app_with_multiple_server_components-->\n'
          '  </body>\n'
          '</html>\n'
          '',
        ),
      );
    });

    testServer('renders client components nested inside server components nested inside client components', (
      tester,
    ) async {
      tester.pumpComponent(AppWithServerComponent(child: div([App1()])));

      final response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body>\n'
          '    <!--@app_with_server_component data<{"child":"s@1"}>-->\n'
          '    <div data-app="with-child"><!--s@1--><div><!--@app1--><div data-app="1"></div><!--/@app1--></div><!--/s@1--></div>\n'
          '    <!--/@app_with_server_component-->\n'
          '  </body>\n'
          '</html>\n'
          '',
        ),
      );
    });

    testServer('renders client components directly nested as server components inside client components', (
      tester,
    ) async {
      tester.pumpComponent(AppWithServerComponent(child: App1()));

      final response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body>\n'
          '    <!--@app_with_server_component data<{"child":"s@1"}>-->\n'
          '    <div data-app="with-child"><!--s@1--><!--@app1--><div data-app="1"></div><!--/@app1--><!--/s@1--></div>\n'
          '    <!--/@app_with_server_component-->\n'
          '  </body>\n'
          '</html>\n'
          '',
        ),
      );
    });

    testServer('renders server components inside custom model parameter', (tester) async {
      tester.pumpComponent(AppWithCustomModel(model: ModelWithComponent(span([text('Custom Model')]))));

      final response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body>\n'
          '    <!--@app_with_custom_model data<{"model":{"child":"s@1"}}>-->\n'
          '    <div data-app="with-model"><!--s@1--><span>Custom Model</span><!--/s@1--></div>\n'
          '    <!--/@app_with_custom_model-->\n'
          '  </body>\n'
          '</html>\n'
          '',
        ),
      );
    });

    testServer('encodes applied params above client component in marker', (tester) async {
      tester.pumpComponent(
        Component.apply(
          classes: 'outer-class',
          id: 'outer-id',
          child: App1(),
        ),
      );

      final response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body>\n'
          '    <!--@app1 apply<[{"i":"outer-id","c":"outer-class"}]>-->\n'
          '    <div id="outer-id" class="outer-class" data-app="1"></div>\n'
          '    <!--/@app1-->\n'
          '  </body>\n'
          '</html>\n'
          '',
        ),
      );
    });

    testServer('encodes applied params above client component wrapping server component', (tester) async {
      tester.pumpComponent(
        Component.apply(
          target: const ApplyTarget.descendantWith(),
          classes: 'server-class',
          child: AppWithServerComponent(
            child: span(classes: 'child-class', [text('Hello')]),
          ),
        ),
      );

      final response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body>\n'
          '    <!--@app_with_server_component data<{"child":"s@1"}> apply<[{"t":{"d":true},"c":"server-class"}]>-->\n'
          '    <div class="server-class" data-app="with-child">\n'
          '      <!--s@1-->\n'
          '      <span class="child-class server-class" data-j-apply="c:server-class">Hello</span>\n'
          '      <!--/s@1-->\n'
          '    </div>\n'
          '    <!--/@app_with_server_component-->\n'
          '  </body>\n'
          '</html>\n'
          '',
        ),
      );
    });
    testServer('does not encode direct child apply params when separated by a render element', (tester) async {
      tester.pumpComponent(
        Component.apply(
          target: ApplyTarget.anyChild,
          classes: 'parent-class',
          child: div([
            App1(),
          ]),
        ),
      );

      final response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body><div class="parent-class"><!--@app1--><div data-app="1"></div><!--/@app1--></div></body>\n'
          '</html>\n'
          '',
        ),
      );
    });

    testServer('encodes descendant apply params even when separated by a render element', (tester) async {
      tester.pumpComponent(
        Component.apply(
          target: const ApplyTarget.descendantWith(),
          classes: 'descendant-class',
          child: div([
            App1(),
          ]),
        ),
      );

      final response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body>\n'
          '    <div class="descendant-class">\n'
          '      <!--@app1 apply<[{"t":{"d":true},"c":"descendant-class"}]>-->\n'
          '      <div class="descendant-class" data-app="1"></div>\n'
          '      <!--/@app1-->\n'
          '    </div>\n'
          '  </body>\n'
          '</html>\n'
          '',
        ),
      );
    });

    testServer('does not add data-j-apply to server elements without client boundary above', (tester) async {
      tester.pumpComponent(
        div([
          Component.apply(
            classes: 'pure-server-applied',
            child: div([
              p([text('pure server')]),
            ]),
          ),
          App1(),
        ]),
      );

      final response = await tester.request('/');

      expect(
        response.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html>\n'
          '  <head><script src="/main.clients.dart.js" defer></script></head>\n'
          '  <body>\n'
          '    <div>\n'
          '      <div class="pure-server-applied"><p>pure server</p></div>\n'
          '      <!--@app1-->\n'
          '      <div data-app="1"></div>\n'
          '      <!--/@app1-->\n'
          '    </div>\n'
          '  </body>\n'
          '</html>\n'
          '',
        ),
      );
    });
    testServer('escapes special characters in data-j-apply on server components', (tester) async {
      tester.pumpComponent(
        Component.apply(
          target: const ApplyTarget.descendantWith(tag: 'span'),
          id: 'test;1,2%3',
          classes: 'c;1 c,2',
          child: AppWithServerComponent(
            child: span([text('Hello')]),
          ),
        ),
      );

      final response = await tester.request('/');

      expect(
        response.body,
        contains('data-j-apply="i:test%3B1%2C2%253;c:c%3B1,c%2C2"'),
      );
    });
    testServer('encodes direct child apply params across fragments', (tester) async {
      tester.pumpComponent(
        Component.apply(
          classes: 'fragment-applied',
          child: Component.fragment([
            App1(),
          ]),
        ),
      );

      final response = await tester.request('/');

      expect(
        response.body,
        contains('<!--@app1 apply<[{"c":"fragment-applied"}]>-->'),
      );
    });

    testServer('does not add data-j-apply for server-only apply inside server component', (tester) async {
      tester.pumpComponent(
        AppWithServerComponent(
          child: Component.apply(
            classes: 'server-only',
            child: span(classes: 'child-class', [text('Hello')]),
          ),
        ),
      );

      final response = await tester.request('/');

      expect(
        response.body,
        contains('<span class="child-class server-only">Hello</span>'),
      );
      expect(
        response.body,
        isNot(contains('data-j-apply')),
      );
    });

    testServer('only includes client-managed params in data-j-apply when server component has its own apply', (
      tester,
    ) async {
      tester.pumpComponent(
        Component.apply(
          target: const ApplyTarget.descendantWith(tag: 'span'),
          classes: 'client-managed',
          child: AppWithServerComponent(
            child: Component.apply(
              classes: 'server-only',
              child: span(classes: 'child-class', [text('Hello')]),
            ),
          ),
        ),
      );

      final response = await tester.request('/');

      expect(
        response.body,
        contains('<span class="child-class server-only client-managed" data-j-apply="c:client-managed">Hello</span>'),
      );
    });

    testServer('emits data-j-apply for apply inside a client component nested in a server component', (tester) async {
      tester.pumpComponent(
        AppWithServerComponent(
          child: div([
            Component.apply(
              target: const ApplyTarget.descendantWith(tag: 'span'),
              classes: 'inner-client-applied',
              child: AppWithServerComponent(
                child: span(classes: 'child-class', [text('Hello')]),
              ),
            ),
          ]),
        ),
      );

      final response = await tester.request('/');

      expect(
        response.body,
        contains('<span class="child-class inner-client-applied" data-j-apply="c:inner-client-applied">Hello</span>'),
      );
    });
  });
}
