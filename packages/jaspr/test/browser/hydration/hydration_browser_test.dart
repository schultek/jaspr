@TestOn('browser')

import 'dart:js_interop';

import 'package:jaspr/browser.dart';
import 'package:jaspr/src/foundation/marker_utils.dart';
import 'package:jaspr_test/browser_test.dart';
import 'package:universal_web/web.dart';

void main() {
  group('hydration browser test', () {
    testBrowser('should hydrate elements', (tester) async {
      window.document.body!.innerHTML = '<div><p>Hello <b>World</b>!</p></div>'.toJS;

      final divElement = window.document.querySelector('body div')!;
      final pElement = window.document.querySelector('body p')!;
      final bElement = window.document.querySelector('body b')!;

      expect(divElement.parentNode, equals(window.document.body));
      expect(pElement.parentNode, equals(divElement));
      expect(bElement.parentNode, equals(pElement));

      tester.pumpComponent(div([
        p([
          text('Hello '),
          b([text('World2')]),
          text('!')
        ]),
      ]));

      expect(divElement.parentNode, equals(window.document.body));
      expect(pElement.parentNode, equals(divElement));
      expect(bElement.parentNode, equals(pElement));

      expect(bElement.textContent, equals('World2'));
    });

    testBrowser('should find and hydrate marker', (tester) async {
      var marker = componentMarkerPrefix;
      window.document.body!.innerHTML = '<div>'
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

      registerClientsSync({
        'app': (_) => p([text('C')]),
      });
      await pumpEventQueue();

      expect(divElement.parentNode, equals(window.document.body));
      expect(p1Element.parentNode, equals(divElement));
      expect(p1Element.textContent, equals('A'));
      expect(p2Element.parentNode, equals(divElement));
      expect(p2Element.textContent, equals('C'));
    });

    testBrowser('should find and hydrate multiple markers with params', (tester) async {
      var marker = componentMarkerPrefix;
      window.document.body!.innerHTML = '<div>'
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

      registerClientsSync({
        'app': (params) => p([text('Hello ${params.get('name')}')]),
      });
      await pumpEventQueue();

      expect(divElement.parentNode, equals(window.document.body));
      expect(p1Element.parentNode, equals(divElement));
      expect(p1Element.textContent, equals('Hello A'));
      expect(p2Element.parentNode, equals(divElement));
      expect(p2Element.textContent, equals('Hello B'));
    });
  });
}
