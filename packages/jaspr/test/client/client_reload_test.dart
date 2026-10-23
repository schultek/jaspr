@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:jaspr/client.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/src/client/dom_render_object.dart' show RootDomRenderObject;
import 'package:jaspr/src/dom/validator.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart' as web;

void main() {
  group('client reload', () {
    testClient('should not duplicate dom nodes on reload when child updates state', (tester) async {
      tester.pumpComponent(const App());
      await pumpEventQueue();

      expect(web.document.querySelectorAll('.main > div').length, equals(1));
      expect(web.document.querySelectorAll('header').length, equals(1));
      expect(web.document.querySelectorAll('section').length, equals(1));
      expect(web.document.querySelector('button')!.textContent, equals('Count: 0'));

      // Click button before reload
      await tester.click(find.tag('button'));
      expect(web.document.querySelector('button')!.textContent, equals('Count: 1'));

      // Simulate client reload with an empty body as returned in client mode
      final oldButton = web.document.querySelector('button')!;
      final newBody = web.document.createElement('body') as web.HTMLBodyElement;
      final root = tester.binding.rootElement!;
      (root.renderObject as RootDomRenderObject).setRootNode(newBody);
      root.owner.performReload(root);
      web.document.body!.replaceWith(newBody);
      tester.binding.completeInitialFrame();
      await pumpEventQueue();

      // Check for duplicated DOM nodes after reload
      expect(web.document.querySelectorAll('.main > div').length, equals(1));
      expect(web.document.querySelectorAll('header').length, equals(1));
      expect(web.document.querySelectorAll('section').length, equals(1));

      // Assert that new nodes in newBody are active and interactive
      final newButton = web.document.querySelector('button')!;
      expect(identical(newButton, oldButton), isFalse);
      expect(newBody.contains(newButton), isTrue);

      await tester.click(find.tag('button'));
      expect(newButton.textContent, equals('Count: 2'));
    });

    testClient('should reload unchanged components without duplicating dom nodes', (tester) async {
      tester.pumpComponent(const ConstApp());
      await pumpEventQueue();

      expect(web.document.querySelectorAll('.main > div').length, equals(1));

      final newBody = web.document.createElement('body') as web.HTMLBodyElement;
      final root = tester.binding.rootElement!;
      (root.renderObject as RootDomRenderObject).setRootNode(newBody);
      root.owner.performReload(root);
      web.document.body!.replaceWith(newBody);
      tester.binding.completeInitialFrame();
      await pumpEventQueue();

      expect(web.document.querySelectorAll('.main > div').length, equals(1));
    });

    testClient('should update client component parameters and sync state on reload and use new nodes', (tester) async {
      final marker = DomValidator.clientMarkerPrefix;
      web.document.body!.innerHTML =
          '<div>'
                  '  <!--${marker}reload_app data={"name": "Alpha"}-->'
                  '  <!--\${"count": 10}-->'
                  '  <p>Fallback</p>'
                  '  <!--/${marker}reload_app-->'
                  '</div>'
              .toJS;

      Jaspr.initializeApp(
        options: ClientOptions(
          clients: () => {
            'reload_app': ClientLoader((params) {
              return SyncReloadComponent(name: params.get<String>('name'));
            }),
          },
        ),
      );

      tester.pumpComponent(const ClientApp());
      await pumpEventQueue();

      final oldP = web.document.querySelector('body p')!;
      expect(oldP.textContent, equals('Hello Alpha, Count: 10'));

      // Perform reload with updated HTML, parameters and sync state
      final newBody = web.document.createElement('body') as web.HTMLBodyElement;
      newBody.innerHTML =
          '<div>'
                  '  <!--${marker}reload_app data={"name": "Beta"}-->'
                  '  <!--\${"count": 20}-->'
                  '  <p>Fallback</p>'
                  '  <!--/${marker}reload_app-->'
                  '</div>'
              .toJS;

      final rootElement = tester.binding.rootElement!;
      final rootRenderObject = rootElement.renderObject as RootDomRenderObject;
      rootRenderObject.setRootNode(newBody);
      rootElement.owner.performReload(rootElement);

      web.document.body!.replaceWith(newBody);
      tester.binding.completeInitialFrame();
      await pumpEventQueue();

      final newP = web.document.querySelector('body p')!;
      expect(newP.textContent, equals('Hello Beta, Count: 20'));
      expect(identical(newP, oldP), isFalse);
      expect(newBody.contains(newP), isTrue);

      // Verify interactivity on the reloaded node
      final button = web.document.querySelector('button')! as web.HTMLButtonElement;
      expect(newBody.contains(button), isTrue);
      button.click();
      await pumpEventQueue();
      expect(newP.textContent, equals('Hello Beta, Count: 21'));
    });

    testClient('should not duplicate nodes in client component when child triggers rebuild during reload', (
      tester,
    ) async {
      final marker = DomValidator.clientMarkerPrefix;
      web.document.body!.innerHTML =
          '<div id="container">'
                  '  <!--${marker}dynamic_app data={"title": "V1"}-->'
                  '  <!--/${marker}dynamic_app-->'
                  '</div>'
              .toJS;

      Jaspr.initializeApp(
        options: ClientOptions(
          clients: () => {
            'dynamic_app': ClientLoader((params) {
              return DynamicClientApp(title: params.get<String>('title'));
            }),
          },
        ),
      );

      tester.pumpComponent(const ClientApp());
      await pumpEventQueue();

      expect(web.document.querySelectorAll('#container .nested-card').length, equals(1));
      expect(web.document.querySelector('h2')!.textContent, equals('V1'));

      // Perform reload with V2
      final newBody = web.document.createElement('body') as web.HTMLBodyElement;
      newBody.innerHTML =
          '<div id="container">'
                  '  <!--${marker}dynamic_app data={"title": "V2"}-->'
                  '  <!--/${marker}dynamic_app-->'
                  '</div>'
              .toJS;

      final rootElement = tester.binding.rootElement!;
      final rootRenderObject = rootElement.renderObject as RootDomRenderObject;
      rootRenderObject.setRootNode(newBody);
      rootElement.owner.performReload(rootElement);

      web.document.body!.replaceWith(newBody);
      tester.binding.completeInitialFrame();
      await pumpEventQueue();

      expect(web.document.querySelectorAll('#container .nested-card').length, equals(1));
      expect(web.document.querySelector('h2')!.textContent, equals('V2'));
    });
  });
}

class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'main', [
      // Non-const to trigger updateChild canUpdate path (similar to Router)
      NestedStateful(),
    ]);
  }
}

class ConstApp extends StatelessComponent {
  const ConstApp({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'main', [
      const ConstChild(),
    ]);
  }
}

class ConstChild extends StatelessComponent {
  const ConstChild({super.key});

  @override
  Component build(BuildContext context) {
    return div([text('Static content')]);
  }
}

class NestedStateful extends StatefulComponent {
  NestedStateful({super.key});

  @override
  State<NestedStateful> createState() => _NestedStatefulState();
}

class _NestedStatefulState extends State<NestedStateful> {
  int count = 0;

  @override
  void didUpdateComponent(NestedStateful oldComponent) {
    super.didUpdateComponent(oldComponent);
    // Simulates RouterState.didUpdateComponent or any stateful component updating state
    setState(() {});
  }

  @override
  Component build(BuildContext context) {
    return div([
      header([text('Header')]),
      section([
        text('Content'),
        button(
          onClick: () => setState(() => count++),
          [text('Count: $count')],
        ),
      ]),
    ]);
  }
}

class SyncReloadComponent extends StatefulComponent {
  const SyncReloadComponent({required this.name, super.key});
  final String name;

  @override
  State<SyncReloadComponent> createState() => _SyncReloadComponentState();
}

class _SyncReloadComponentState extends State<SyncReloadComponent>
    with SyncStateMixin<SyncReloadComponent, Map<String, dynamic>> {
  int count = 0;

  @override
  void updateState(Map<String, dynamic> value) {
    count = value['count'] as int;
  }

  @override
  Map<String, dynamic> getState() => {'count': count};

  @override
  Component build(BuildContext context) {
    return div([
      p([text('Hello ${component.name}, Count: $count')]),
      button(
        onClick: () => setState(() => count++),
        [text('Increment')],
      ),
    ]);
  }
}

class DynamicClientApp extends StatelessComponent {
  const DynamicClientApp({required this.title, super.key});
  final String title;

  @override
  Component build(BuildContext context) {
    return div([
      h2([text(title)]),
      NestedStatefulChild(title: title),
    ]);
  }
}

class NestedStatefulChild extends StatefulComponent {
  NestedStatefulChild({required this.title, super.key});
  final String title;

  @override
  State<NestedStatefulChild> createState() => _NestedStatefulChildState();
}

class _NestedStatefulChildState extends State<NestedStatefulChild> {
  @override
  void didUpdateComponent(NestedStatefulChild oldComponent) {
    super.didUpdateComponent(oldComponent);
    setState(() {});
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'nested-card', [
      text('Card for ${component.title}'),
    ]);
  }
}
