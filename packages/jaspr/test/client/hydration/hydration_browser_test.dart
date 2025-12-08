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
            'app': ClientLoader((params) => p([Component.text('Hello ${params['name']}')])),
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
  });
}
