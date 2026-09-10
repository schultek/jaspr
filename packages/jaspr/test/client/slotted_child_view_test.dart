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

    testClient('ignores whitespace between applied class names', (tester) async {
      window.document.body!.innerHTML = '<div>Content</div>'.toJS;

      tester.pumpComponent(
        Component.apply(
          classes: '  outer\tselected\n ',
          child: SlottedChildView(slots: const []),
        ),
      );

      final element = window.document.querySelector('body > div')!;
      expect(element.classList.contains('outer'), isTrue);
      expect(element.classList.contains('selected'), isTrue);
      expect(element.classList.length, 2);
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

    testClient('applies direct child params to root range slot', (tester) async {
      window.document.body!.innerHTML = '<!--start--><button>Click me</button><!--end-->'.toJS;
      final start = window.document.body!.firstChild!;
      final end = window.document.body!.lastChild!;

      tester.pumpComponent(
        Component.apply(
          classes: 'highlighted',
          attributes: const {'data-outer': 'true'},
          child: SlottedChildView(
            slots: [
              ChildSlot.between(
                start: start,
                end: end,
                child: button([Component.text('Click me')]),
              ),
            ],
          ),
        ),
      );

      final btn = window.document.querySelector('button')!;
      expect(btn.classList.contains('highlighted'), isTrue);
      expect(btn.getAttribute('data-outer'), 'true');
    });

    testClient('preserves selector isolation with multiple apply components', (tester) async {
      window.document.body!.innerHTML =
          '<!--start-btn--><button>Btn</button><!--end-btn--><!--start-a--><a href="#">Link</a><!--end-a-->'.toJS;
      final startBtn = window.document.body!.childNodes.item(0)!;
      final endBtn = window.document.body!.childNodes.item(2)!;
      final startA = window.document.body!.childNodes.item(3)!;
      final endA = window.document.body!.childNodes.item(5)!;

      tester.pumpComponent(
        Component.apply(
          target: ApplyTarget.childWith(tag: 'button'),
          classes: 'btn-class',
          child: Component.apply(
            target: ApplyTarget.childWith(tag: 'a'),
            classes: 'link-class',
            child: SlottedChildView(
              slots: [
                ChildSlot.between(
                  start: startBtn,
                  end: endBtn,
                  child: button([Component.text('Btn')]),
                ),
                ChildSlot.between(
                  start: startA,
                  end: endA,
                  child: a(href: '#', [Component.text('Link')]),
                ),
              ],
            ),
          ),
        ),
      );

      final btn = window.document.querySelector('button')!;
      final link = window.document.querySelector('a')!;
      expect(btn.classList.contains('btn-class'), isTrue);
      expect(btn.classList.contains('link-class'), isFalse);
      expect(link.classList.contains('link-class'), isTrue);
      expect(link.classList.contains('btn-class'), isFalse);
    });
  });
}
