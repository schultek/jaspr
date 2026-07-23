@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:jaspr/client.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart';

void main() {
  group('slotted child view', () {
    testClient('renders child at slot', (tester) async {
      window.document.body!.innerHTML = '<div><p>Hello World</p></div>'.toJS;

      tester.pumpComponent(
        SlottedChildView(
          slots: [
            ChildSlot.fromQuery('p', child: Component.text('Hello Test')),
          ],
        ),
      );

      expect(
        (window.document.body!.innerHTML as JSString).toDart,
        '<div><p>Hello Test</p></div>',
      );
    });

    testClient('renders multiple slots', (tester) async {
      window.document.body!.innerHTML =
          '<div><div id="header">Header</div><main>Content</main><footer>Footer</footer></div>'.toJS;

      tester.pumpComponent(
        SlottedChildView(
          slots: [
            ChildSlot.fromQuery('#header', child: Component.text('Test Header')),
            ChildSlot.fromQuery('footer', child: Component.text('Test Footer')),
          ],
        ),
      );

      expect(
        (window.document.body!.innerHTML as JSString).toDart,
        '<div><div id="header">Test Header</div><main>Content</main><footer>Test Footer</footer></div>',
      );
    });

    testClient('uses inherited dom params', (tester) async {
      window.document.body!.innerHTML = '<div><div id="header">Header</div><main>Content</main></div>'.toJS;

      tester.pumpComponent(
        Component.apply(
          classes: 'outer',
          child: Component.apply(
            target: ApplyTarget.descendantWith(tag: 'div'),
            classes: 'box',
            child: SlottedChildView(
              slots: [
                ChildSlot.fromQuery('main', child: div([Component.text('Test Content')])),
              ],
            ),
          ),
        ),
      );

      expect(
        (window.document.body!.innerHTML as JSString).toDart,
        '<div class="box outer"><div id="header" class="box">Header</div><main><div class="box">Test Content</div></main></div>',
      );
    });

    testClient('cleans up applied params and events on unmount', (tester) async {
      window.document.body!.innerHTML = '<div><p>Hello World</p></div>'.toJS;

      var clicked = 0;

      tester.pumpComponent(
        Component.apply(
          target: ApplyTarget.descendantWith(tag: 'p'),
          id: 'new-id',
          classes: 'box',
          styles: Styles(color: Colors.red),
          attributes: {'data-test': 'value'},
          events: {'click': (e) => clicked++},
          child: SlottedChildView(
            slots: [
              ChildSlot.fromQuery('p', child: Component.text('Test')),
            ],
          ),
        ),
      );

      final pElement = window.document.getElementById('new-id') as HTMLElement?;
      expect(pElement, isNotNull);
      expect(pElement!.classList.contains('box'), isTrue);
      expect(pElement.style.color, 'red');
      expect(pElement.getAttribute('data-test'), 'value');

      // Trigger click
      pElement.click();
      expect(clicked, 1);

      // Now unmount the component tree to test cleanup
      tester.binding.detachRootComponent();

      // Check that the target element parameters are reset!
      expect(pElement.id, isEmpty);
      expect(pElement.classList.contains('box'), isFalse);
      expect(pElement.style.color, isEmpty);
      expect(pElement.hasAttribute('data-test'), isFalse);

      // Trigger click again - should not increment clicked
      pElement.click();
      expect(clicked, 1);
    });
  });
}
