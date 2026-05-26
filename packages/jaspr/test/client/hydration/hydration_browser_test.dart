@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:jaspr/client.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/src/dom/validator.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart';

void main() {
  group('hydration browser test', () {
    testClient('should hydrate elements', (tester) async {
      window.document.body!.innerHTML = '<div><p>Hello <b>World</b>!</p></div>'.toJS;

      final divElement = window.document.querySelector('body div')!;
      final pElement = window.document.querySelector('body p')!;
      final bElement = window.document.querySelector('body b')!;

      expect(divElement.parentNode, equals(window.document.body));
      expect(pElement.parentNode, equals(divElement));
      expect(bElement.parentNode, equals(pElement));

      final pKey = GlobalNodeKey();
      final bKey = GlobalNodeKey();

      tester.pumpComponent(
        div([
          p(key: pKey, [
            Component.text('Hello '),
            b(key: bKey, [Component.text('World2')]),
            Component.text('!'),
          ]),
        ]),
      );

      expect(divElement.parentNode, equals(window.document.body));
      expect(pElement.parentNode, equals(divElement));
      expect(bElement.parentNode, equals(pElement));

      expect(pKey.currentNode, equals(pElement));
      expect(bKey.currentNode, equals(bElement));

      expect(bElement.textContent, equals('World2'));
    });

    testClient('should find and hydrate marker', (tester) async {
      final marker = DomValidator.clientMarkerPrefix;
      window.document.body!.innerHTML =
          '<div>'
                  '  <p>A</p>'
                  '  <!--${marker}app-->'
                  '  <p>B</p>'
                  '  <!--/${marker}app-->'
                  '</div>'
              .toJS;

      final divElement = window.document.querySelector('body div')!;
      final p1Element = window.document.querySelector('body p:first-child')!;
      final p2Element = window.document.querySelector('body p:last-child')!;

      expect(divElement.parentNode, equals(window.document.body));
      expect(p1Element.parentNode, equals(divElement));
      expect(p1Element.textContent, equals('A'));
      expect(p2Element.parentNode, equals(divElement));
      expect(p2Element.textContent, equals('B'));

      Jaspr.initializeApp(
        options: ClientOptions(
          clients: {
            'app': ClientLoader((_) => p([Component.text('C')])),
          },
        ),
      );

      runApp(const ClientApp());
      await pumpEventQueue();

      expect(divElement.parentNode, equals(window.document.body));
      expect(p1Element.parentNode, equals(divElement));
      expect(p1Element.textContent, equals('A'));
      expect(p2Element.parentNode, equals(divElement));
      expect(p2Element.textContent, equals('C'));
    });

    testClient('should find and hydrate multiple markers with params', (tester) async {
      final marker = DomValidator.clientMarkerPrefix;
      window.document.body!.innerHTML =
          '<div>'
                  '  <!--${marker}app data={"name": "A"}-->'
                  '  <p>Hello</p>'
                  '  <!--/${marker}app-->'
                  '  <!--${marker}app data={"name": "B"}-->'
                  '  <p>Hello</p>'
                  '  <!--/${marker}app-->'
                  '</div>'
              .toJS;

      final divElement = window.document.querySelector('body div')!;
      final p1Element = window.document.querySelector('body p:first-child')!;
      final p2Element = window.document.querySelector('body p:last-child')!;

      expect(divElement.parentNode, equals(window.document.body));
      expect(p1Element.parentNode, equals(divElement));
      expect(p1Element.textContent, equals('Hello'));
      expect(p2Element.parentNode, equals(divElement));
      expect(p2Element.textContent, equals('Hello'));

      Jaspr.initializeApp(
        options: ClientOptions(
          clients: {
            'app': ClientLoader((params) => p([Component.text('Hello ${params.get<String>('name')}')])),
          },
        ),
      );

      runApp(const ClientApp());
      await pumpEventQueue();

      expect(divElement.parentNode, equals(window.document.body));
      expect(p1Element.parentNode, equals(divElement));
      expect(p1Element.textContent, equals('Hello A'));
      expect(p2Element.parentNode, equals(divElement));
      expect(p2Element.textContent, equals('Hello B'));
    });

    testClient('should find and hydrate client component with nested server component', (tester) async {
      final marker = DomValidator.clientMarkerPrefix;
      window.document.body!.innerHTML =
          '<div>'
                  '  <!--${marker}app data={"child":"s${marker}1"}-->'
                  '  <p>'
                  '    <!--s${marker}1-->'
                  '    <span>Server Element</span>'
                  '    <!--/s${marker}1-->'
                  '  </p>'
                  '  <!--/${marker}app-->'
                  '</div>'
              .toJS;

      final divElement = window.document.querySelector('body div')!;
      final pElement = window.document.querySelector('body p')!;
      final spanElement = window.document.querySelector('body span')!;

      expect(divElement.parentNode, equals(window.document.body));
      expect(pElement.parentNode, equals(divElement));
      expect(spanElement.parentNode, equals(pElement));
      expect(spanElement.textContent, equals('Server Element'));

      Jaspr.initializeApp(
        options: ClientOptions(
          clients: {
            'app': ClientLoader((params) {
              return p(classes: 'hydrated', [
                params.mount(params.get<String>('child')),
              ]);
            }),
          },
        ),
      );

      tester.pumpComponent(const ClientApp());
      await pumpEventQueue();

      expect(divElement.parentNode, equals(window.document.body));
      expect(pElement.parentNode, equals(divElement));
      expect(pElement.className, 'hydrated');
      expect(spanElement.parentNode, equals(pElement));
      expect(spanElement.textContent, equals('Server Element'));
    });

    testClient('should find and hydrate nested client component inside server component', (tester) async {
      final marker = DomValidator.clientMarkerPrefix;
      window.document.body!.innerHTML =
          '<div>'
                  '  <!--${marker}app data={"child":"s${marker}1"}-->'
                  '  <div>'
                  '    <!--s${marker}1-->'
                  '    <p>'
                  '      <span>Server Element</span>'
                  '      <!--${marker}subapp data={"name":"Nested Client"}-->'
                  '      <strong>Fallback</strong>'
                  '      <!--/${marker}subapp-->'
                  '    </p>'
                  '    <!--/s${marker}1-->'
                  '  </div>'
                  '  <!--/${marker}app-->'
                  '</div>'
              .toJS;

      final divElement = window.document.querySelector('body div')!;
      final outerDivElement = window.document.querySelector('body div > div')!;
      final pElement = window.document.querySelector('body p')!;
      final spanElement = window.document.querySelector('body span')!;
      final strongElement = window.document.querySelector('body strong')!;

      expect(divElement.parentNode, equals(window.document.body));
      expect(outerDivElement.parentNode, equals(divElement));
      expect(pElement.parentNode, equals(outerDivElement));
      expect(spanElement.parentNode, equals(pElement));
      expect(strongElement.parentNode, equals(pElement));
      expect(strongElement.textContent, equals('Fallback'));

      Jaspr.initializeApp(
        options: ClientOptions(
          clients: {
            'app': ClientLoader((params) {
              return div(classes: 'hydrated', [params.mount(params.get<String>('child'))]);
            }),
            'subapp': ClientLoader((params) {
              return strong(classes: 'hydrated', [Component.text('Hello ${params.get<String>('name')}')]);
            }),
          },
        ),
      );

      runApp(const ClientApp());
      await pumpEventQueue();

      expect(divElement.parentNode, equals(window.document.body));
      expect(outerDivElement.parentNode, equals(divElement));
      expect(outerDivElement.className, 'hydrated');
      expect(pElement.parentNode, equals(outerDivElement));
      expect(spanElement.parentNode, equals(pElement));
      expect(strongElement.parentNode, equals(pElement));
      expect(strongElement.className, 'hydrated');
      expect(strongElement.textContent, equals('Hello Nested Client'));
    });

    testClient('should reload client components and update parameters/sync state on performReload', (tester) async {
      final marker = DomValidator.clientMarkerPrefix;
      window.document.body!.innerHTML =
          '<div>'
                  '  <!--${marker}app data={"name": "A"}-->'
                  '  <!--\${"count": 1}-->'
                  '  <p>Fallback</p>'
                  '  <!--/${marker}app-->'
                  '</div>'
              .toJS;

      final divElement = window.document.querySelector('body div')!;
      final pElement = window.document.querySelector('body p')!;

      expect(divElement.parentNode, equals(window.document.body));
      expect(pElement.parentNode, equals(divElement));
      expect(pElement.textContent, equals('Fallback'));

      Jaspr.initializeApp(
        options: ClientOptions(
          clients: {
            'app': ClientLoader((params) {
              return ReloadTestComponent(name: params.get<String>('name'));
            }),
          },
        ),
      );

      tester.pumpComponent(const ClientApp());
      await pumpEventQueue();

      final pElementHydrated = window.document.querySelector('body p')!;
      expect(pElementHydrated.textContent, equals('Hello A, Count: 1'));

      // Perform reload with updated options/sync state
      final newBody = window.document.createElement('body') as HTMLBodyElement;
      newBody.innerHTML =
          '<div>'
                  '  <!--${marker}app data={"name": "B"}-->'
                  '  <!--\${"count": 2}-->'
                  '  <p>Fallback</p>'
                  '  <!--/${marker}app-->'
                  '</div>'
              .toJS;

      final rootElement = tester.binding.rootElement!;
      final rootRenderObject = rootElement.renderObject as RootDomRenderObject;
      rootRenderObject.setRootNode(newBody);
      rootElement.owner.performReload(rootElement);

      window.document.body!.replaceWith(newBody);
      await pumpEventQueue();

      final pElementReloaded = window.document.querySelector('body p')!;
      expect(pElementReloaded.textContent, equals('Hello B, Count: 2'));
    });
  });
}

class ReloadTestComponent extends StatefulComponent {
  const ReloadTestComponent({required this.name, super.key});
  final String name;
  @override
  State<ReloadTestComponent> createState() => ReloadTestComponentState();
}

class ReloadTestComponentState extends State<ReloadTestComponent>
    with SyncStateMixin<ReloadTestComponent, Map<String, dynamic>> {
  int count = 0;

  @override
  void updateState(Map<String, dynamic> value) {
    count = value['count'] as int;
  }

  @override
  Map<String, dynamic> getState() => {'count': count};

  @override
  Component build(BuildContext context) {
    return p([Component.text('Hello ${component.name}, Count: $count')]);
  }
}
