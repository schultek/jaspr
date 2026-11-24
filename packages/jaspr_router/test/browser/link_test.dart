@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:web/web.dart' as web;

import '../utils.dart';

void main() {
  group('link', () {
    // Whether the last click reached the document with its default action prevented,
    // i.e. whether the link handled the click itself instead of leaving it to the browser.
    bool? clickDefaultPrevented;

    setUp(() {
      clickDefaultPrevented = null;
      final listener = ((web.Event event) {
        clickDefaultPrevented = event.defaultPrevented;
        // Keep the browser from following the link and navigating away from the test page.
        event.preventDefault();
      }).toJS;
      web.document.addEventListener('click', listener);
      addTearDown(() => web.document.removeEventListener('click', listener));
    });

    void pumpLink(ClientTester tester, {Target? target, Map<String, String>? attributes}) {
      tester.pumpComponent(
        Router(
          routes: [
            Route(
              path: '/',
              builder: (_, _) => Link(
                to: '/a',
                target: target,
                attributes: attributes,
                child: Component.text('link'),
              ),
            ),
            route('/a'),
          ],
        ),
      );
    }

    Future<void> clickLink(ClientTester tester, web.MouseEventInit init) {
      init
        ..bubbles = true
        ..cancelable = true;
      return tester.dispatchEvent(find.tag('a'), web.MouseEvent('click', init));
    }

    void expectHandledByRouter() {
      expect(find.text('a'), findsOneComponent);
      expect(clickDefaultPrevented, isTrue);
    }

    void expectLeftToBrowser() {
      expect(find.text('link'), findsOneComponent);
      expect(find.text('a'), findsNothing);
      expect(clickDefaultPrevented, isFalse);
    }

    testClient('should navigate on a plain primary click', (tester) async {
      pumpLink(tester);

      await clickLink(tester, web.MouseEventInit());

      expectHandledByRouter();
    });

    for (final (name, init) in [
      ('the ctrl key', web.MouseEventInit(ctrlKey: true)),
      ('the meta key', web.MouseEventInit(metaKey: true)),
      ('the shift key', web.MouseEventInit(shiftKey: true)),
      ('the alt key', web.MouseEventInit(altKey: true)),
      ('the middle button', web.MouseEventInit(button: 1)),
    ]) {
      testClient('should leave a click with $name to the browser', (tester) async {
        pumpLink(tester);

        await clickLink(tester, init);

        expectLeftToBrowser();
      });
    }

    testClient('should not navigate when the click was already prevented', (tester) async {
      pumpLink(tester);

      final listener = ((web.Event event) => event.preventDefault()).toJS;
      web.document.addEventListener('click', listener, true.toJS);
      addTearDown(() => web.document.removeEventListener('click', listener, true.toJS));

      await clickLink(tester, web.MouseEventInit());

      expect(find.text('link'), findsOneComponent);
      expect(find.text('a'), findsNothing);
    });

    testClient('should leave a click on a link with target _blank to the browser', (tester) async {
      pumpLink(tester, target: Target.blank);

      await clickLink(tester, web.MouseEventInit());

      expectLeftToBrowser();
    });

    testClient('should navigate on a click on a link with target _self', (tester) async {
      pumpLink(tester, target: Target.self);

      await clickLink(tester, web.MouseEventInit());

      expectHandledByRouter();
    });

    testClient('should leave a click on a link with a download attribute to the browser', (tester) async {
      pumpLink(tester, attributes: {'download': ''});

      await clickLink(tester, web.MouseEventInit());

      expectLeftToBrowser();
    });
  });
}
