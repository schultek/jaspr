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

    testClient('renders into an empty range slot between its anchors', (tester) async {
      window.document.body!.innerHTML = '<p>Before</p><!--start--><!--end--><p>After</p>'.toJS;
      final start = window.document.body!.childNodes.item(1)!;
      final end = window.document.body!.childNodes.item(2)!;

      tester.pumpComponent(
        SlottedChildView(
          slots: [
            ChildSlot.between(start: start, end: end, child: span([.text('Slotted')])),
          ],
        ),
      );

      expect(
        (window.document.body!.innerHTML as JSString).toDart,
        '<p>Before</p><!--start--><span>Slotted</span><!--end--><p>After</p>',
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

    testClient('cleans up descendant params when the target changes to direct children', (tester) async {
      window.document.body!.innerHTML = '<section><button class="original">Static</button></section>'.toJS;
      var descendants = true;
      late void Function(void Function() cb) setState;
      var clicks = 0;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .apply(
              target: descendants ? .descendantWith(tag: 'button') : .childWith(tag: 'button'),
              id: 'applied-id',
              classes: 'applied',
              styles: Styles(color: Colors.red),
              attributes: const {'data-applied': 'true'},
              events: {'click': (_) => clicks++},
              child: SlottedChildView(slots: const []),
            );
          },
        ),
      );

      final btn = window.document.querySelector('button')! as HTMLElement;
      expect(btn.id, 'applied-id');
      expect(btn.className, 'original applied');
      expect(btn.style.color, 'red');
      expect(btn.getAttribute('data-applied'), 'true');
      btn.click();
      expect(clicks, 1);

      setState(() => descendants = false);
      await pumpEventQueue();

      expect(btn.id, isEmpty);
      expect(btn.className, 'original');
      expect(btn.style.color, isEmpty);
      expect(btn.hasAttribute('data-applied'), isFalse);
      btn.click();
      expect(clicks, 1);
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

    testClient('hands applied params over to a slot added after the first build', (tester) async {
      window.document.body!.innerHTML = '<!--start--><button>Static</button><!--end-->'.toJS;
      final start = window.document.body!.firstChild!;
      final end = window.document.body!.lastChild!;
      var slotted = false;
      late void Function(void Function() cb) setState;
      var clicks = 0;

      tester.pumpComponent(
        .apply(
          target: ApplyTarget.descendantWith(tag: 'button'),
          classes: 'applied',
          attributes: const {'data-applied': 'true'},
          events: {'click': (_) => clicks++},
          child: StatefulBuilder(
            builder: (context, set) {
              setState = set;
              return SlottedChildView(
                slots: [
                  if (slotted) ChildSlot.between(start: start, end: end, child: button([.text('Hydrated')])),
                ],
              );
            },
          ),
        ),
      );

      final btn = window.document.querySelector('button')! as HTMLElement;
      expect(btn.classList.contains('applied'), isTrue);
      btn.click();
      expect(clicks, 1);

      setState(() => slotted = true);
      await pumpEventQueue();

      expect(window.document.querySelector('button'), equals(btn));
      expect(btn.textContent, 'Hydrated');
      expect(btn.classList.contains('applied'), isTrue);
      expect(btn.getAttribute('data-applied'), 'true');
      btn.click();
      expect(clicks, 2);
    });

    for (final query in ['#mount-target', '.mount-target', '[data-target="true"]']) {
      testClient('resolves a new query slot using applied values in $query', (tester) async {
        window.document.body!.innerHTML = '<section><main>Fallback</main></section>'.toJS;
        final mainElement = window.document.querySelector('main')!;
        var slotted = false;
        var enabled = true;
        var text = 'Hydrated';
        late void Function(void Function() cb) setParams;
        late void Function(void Function() cb) setSlot;

        tester.pumpComponent(
          StatefulBuilder(
            builder: (context, set) {
              setParams = set;
              return .apply(
                target: const .descendantWith(tag: 'main'),
                id: enabled ? 'mount-target' : null,
                classes: enabled ? 'mount-target' : null,
                attributes: enabled ? const {'data-target': 'true'} : null,
                child: StatefulBuilder(
                  builder: (context, set) {
                    setSlot = set;
                    return SlottedChildView(
                      slots: [
                        if (slotted) ChildSlot.fromQuery(query, child: span([.text(text)])),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        );

        expect(window.document.querySelector(query), equals(mainElement));

        setSlot(() => slotted = true);
        await pumpEventQueue();
        expect(mainElement.textContent, 'Hydrated');
        expect(window.document.querySelector(query), equals(mainElement));

        // An existing slot keeps its target even when its selector stops matching.
        setParams(() => enabled = false);
        await pumpEventQueue();
        expect(window.document.querySelector(query), isNull);

        setSlot(() => text = 'Updated');
        await pumpEventQueue();
        expect(window.document.querySelector('main'), equals(mainElement));
        expect(mainElement.textContent, 'Updated');
      });
    }

    testClient('resolves a new query slot using params changed in the same build', (tester) async {
      window.document.body!.innerHTML = '<section><main>Fallback</main></section>'.toJS;
      final mainElement = window.document.querySelector('main')!;
      var enabled = false;
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .apply(
              target: const .descendantWith(tag: 'main'),
              classes: enabled ? 'mount-target' : null,
              child: SlottedChildView(
                slots: [
                  if (enabled) ChildSlot.fromQuery('.mount-target', child: span([.text('Hydrated')])),
                ],
              ),
            );
          },
        ),
      );

      expect(mainElement.hasAttribute('class'), isFalse);

      setState(() => enabled = true);
      await pumpEventQueue();

      expect(window.document.querySelector('main'), equals(mainElement));
      expect(mainElement.className, 'mount-target');
      expect(mainElement.textContent, 'Hydrated');
    });

    testClient('removes the listeners of a removed slot', (tester) async {
      window.document.body!.innerHTML = '<!--start--><button>Static</button><!--end-->'.toJS;
      final start = window.document.body!.firstChild!;
      final end = window.document.body!.lastChild!;
      var slotted = true;
      late void Function(void Function() cb) setState;
      var clicks = 0;

      tester.pumpComponent(
        .apply(
          target: const .descendantWith(tag: 'button'),
          events: {'click': (_) => clicks++},
          child: StatefulBuilder(
            builder: (context, set) {
              setState = set;
              return SlottedChildView(
                slots: [
                  if (slotted)
                    ChildSlot.between(
                      start: start,
                      end: end,
                      child: button([.text('Hydrated')]),
                    ),
                ],
              );
            },
          ),
        ),
      );

      final btn = window.document.querySelector('button')! as HTMLElement;
      btn.click();
      expect(clicks, 1);

      setState(() => slotted = false);
      await pumpEventQueue();

      // The view now owns the leftover button, so its handler fires only once.
      expect(window.document.querySelector('button'), equals(btn));
      btn.click();
      expect(clicks, 2);

      tester.binding.detachRootComponent();
      btn.click();
      expect(clicks, 2);
    });

    testClient('does not apply params to adjacent range slots that share an anchor', (tester) async {
      window.document.body!.innerHTML = '<!--a--><button>First</button><!--b--><button>Second</button><!--c-->'.toJS;
      final anchors = window.document.body!.childNodes;
      var clicks = 0;

      tester.pumpComponent(
        .apply(
          target: const .descendantWith(tag: 'button'),
          events: {'click': (_) => clicks++},
          child: SlottedChildView(
            slots: [
              ChildSlot.between(
                start: anchors.item(0)!,
                end: anchors.item(2)!,
                child: button([.text('First')]),
              ),
              ChildSlot.between(
                start: anchors.item(2)!,
                end: anchors.item(4)!,
                child: button([.text('Second')]),
              ),
            ],
          ),
        ),
      );

      final buttons = window.document.querySelectorAll('button');
      expect(buttons.length, 2);
      for (var i = 0; i < buttons.length; i++) {
        (buttons.item(i)! as HTMLElement).click();
      }
      expect(clicks, 2);
    });

    for (final deferred in [false, true]) {
      testClient('resolves inherited selectors in ${deferred ? 'a deferred' : 'an initial'} nested view', (
        tester,
      ) async {
        window.document.body!.innerHTML = '<!--start--><section><main>Fallback</main></section><!--end-->'.toJS;
        final start = window.document.body!.firstChild!;
        final end = window.document.body!.lastChild!;
        final mainElement = window.document.querySelector('main')!;
        var slotted = !deferred;
        late void Function(void Function() cb) setSlot;

        tester.pumpComponent(
          .apply(
            target: const .descendantWith(tag: 'main'),
            classes: 'mount-target',
            child: StatefulBuilder(
              builder: (context, set) {
                setSlot = set;
                return SlottedChildView(
                  slots: [
                    if (slotted)
                      ChildSlot.between(
                        start: start,
                        end: end,
                        child: SlottedChildView(
                          slots: [
                            ChildSlot.fromQuery('.mount-target', child: span([.text('Hydrated')])),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );

        if (deferred) {
          setSlot(() => slotted = true);
          await pumpEventQueue();
        }

        expect(window.document.querySelector('main'), equals(mainElement));
        expect(mainElement.textContent, 'Hydrated');
        expect(mainElement.className, 'mount-target');

        tester.binding.detachRootComponent();
        expect(mainElement.hasAttribute('class'), isFalse);
      });
    }

    for (final querySlot in [false, true]) {
      testClient('hands param ownership to a nested view in a ${querySlot ? 'query' : 'range'} slot', (tester) async {
        window.document.body!.innerHTML =
            '<section><main><!--start-->'
                    '<button class="original" style="background-color: black" data-original="true">Static</button>'
                    '<!--end--></main></section>'
                .toJS;
        final mainElement = window.document.querySelector('main')!;
        final btn = mainElement.querySelector('button')! as HTMLElement;
        const nestedViewKey = ValueKey('nested-view');
        var slotted = false;
        var updated = false;
        var enabled = true;
        late void Function(void Function() cb) setParams;
        late void Function(void Function() cb) setSlot;
        var initialClicks = 0;
        var updatedClicks = 0;

        tester.pumpComponent(
          StatefulBuilder(
            builder: (context, set) {
              setParams = set;
              return .apply(
                target: const .descendantWith(tag: 'button'),
                id: enabled ? (updated ? 'updated-id' : 'initial-id') : null,
                classes: enabled ? (updated ? 'original updated' : 'original initial') : null,
                styles: enabled
                    ? Styles(color: updated ? Colors.blue : Colors.red, backgroundColor: Colors.white)
                    : null,
                attributes: enabled
                    ? {'data-applied': updated ? 'updated' : 'initial', 'data-original': 'override'}
                    : null,
                events: enabled ? {'click': updated ? (_) => updatedClicks++ : (_) => initialClicks++} : null,
                child: StatefulBuilder(
                  builder: (context, set) {
                    setSlot = set;
                    final nestedView = SlottedChildView(key: nestedViewKey, slots: const []);
                    return SlottedChildView(
                      slots: [
                        if (slotted)
                          if (querySlot)
                            // Resolve before releasing the button's inherited class.
                            ChildSlot.fromQuery('main:has(.initial)', child: nestedView)
                          else
                            ChildSlot.between(
                              start: mainElement.firstChild!,
                              end: mainElement.lastChild!,
                              child: nestedView,
                            ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        );

        void expectOriginalParams() {
          expect(btn.hasAttribute('id'), isFalse);
          expect(btn.className, 'original');
          expect(btn.style.color, isEmpty);
          expect(btn.style.backgroundColor, 'black');
          expect(btn.getAttribute('data-original'), 'true');
          expect(btn.hasAttribute('data-applied'), isFalse);
        }

        expect(find.byKey(nestedViewKey), findsNothing);
        btn.click();
        expect(initialClicks, 1);

        setSlot(() => slotted = true);
        await pumpEventQueue();

        expect(find.byKey(nestedViewKey), findsOneComponent);
        expect(mainElement.querySelector('button'), equals(btn));
        expect(btn.id, 'initial-id');
        expect(btn.className, 'original initial');
        expect(btn.style.color, 'red');
        expect(btn.getAttribute('data-applied'), 'initial');
        btn.click();
        expect(initialClicks, 2);

        setParams(() => updated = true);
        await pumpEventQueue();

        expect(btn.id, 'updated-id');
        expect(btn.className, 'original updated');
        expect(btn.style.color, 'blue');
        expect(btn.getAttribute('data-applied'), 'updated');
        btn.click();
        expect(initialClicks, 2);
        expect(updatedClicks, 1);

        setParams(() => enabled = false);
        await pumpEventQueue();

        expectOriginalParams();
        btn.click();
        expect(updatedClicks, 1);

        setParams(() => enabled = true);
        await pumpEventQueue();
        expect(btn.style.color, 'blue');

        tester.binding.detachRootComponent();
        expectOriginalParams();
        btn.click();
        expect(updatedClicks, 1);
      });
    }

    testClient('hands applied params on many elements to a nested view', (tester) async {
      window.document.body!.innerHTML =
          '<!--start--><section>${List.generate(40, (index) => '<button>Item $index</button>').join()}</section><!--end-->'
              .toJS;
      final start = window.document.body!.firstChild!;
      final end = window.document.body!.lastChild!;
      final buttonNodes = window.document.querySelectorAll('button');
      final buttons = [for (var i = 0; i < buttonNodes.length; i++) buttonNodes.item(i)! as HTMLElement];
      const nestedViewKey = ValueKey('nested-view');
      var slotted = false;
      var clicks = 0;
      late void Function(void Function() cb) setSlot;

      tester.pumpComponent(
        .apply(
          target: const .descendantWith(tag: 'button'),
          classes: 'applied',
          events: {'click': (_) => clicks++},
          child: StatefulBuilder(
            builder: (context, set) {
              setSlot = set;
              return SlottedChildView(
                slots: [
                  if (slotted)
                    ChildSlot.between(
                      start: start,
                      end: end,
                      child: SlottedChildView(key: nestedViewKey, slots: const []),
                    ),
                ],
              );
            },
          ),
        ),
      );

      expect(find.byKey(nestedViewKey), findsNothing);
      for (final button in buttons) {
        expect(button.className, 'applied');
        button.click();
      }
      expect(clicks, 40);

      setSlot(() => slotted = true);
      await pumpEventQueue();

      expect(find.byKey(nestedViewKey), findsOneComponent);
      for (final button in buttons) {
        expect(button.className, 'applied');
        button.click();
      }
      expect(clicks, 80);

      tester.binding.detachRootComponent();
      for (final button in buttons) {
        expect(button.hasAttribute('class'), isFalse);
        button.click();
      }
      expect(clicks, 80);
    });

    testClient('applies inner params when adding a slot with a nested view', (tester) async {
      window.document.body!.innerHTML = '<!--start--><button>Static</button><!--end-->'.toJS;
      final start = window.document.body!.firstChild!;
      final end = window.document.body!.lastChild!;
      var slotted = false;
      late void Function(void Function() cb) setSlot;

      tester.pumpComponent(
        .apply(
          target: const .descendantWith(tag: 'button'),
          styles: const Styles(color: Colors.red),
          child: StatefulBuilder(
            builder: (context, set) {
              setSlot = set;
              return SlottedChildView(
                slots: [
                  if (slotted)
                    ChildSlot.between(
                      start: start,
                      end: end,
                      child: .apply(
                        target: const .descendantWith(tag: 'button'),
                        styles: const Styles(color: Colors.blue),
                        child: SlottedChildView(slots: const []),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      );

      final btn = window.document.querySelector('button')! as HTMLElement;
      expect(btn.style.color, 'red');

      setSlot(() => slotted = true);
      await pumpEventQueue();

      expect(window.document.querySelector('button'), equals(btn));
      expect(btn.style.color, 'blue');
    });

    testClient('keeps a single owner for applied params after a reload', (tester) async {
      const html = '<section><p class="target">Static</p><main><button class="target">Server</button></main></section>';
      window.document.body!.innerHTML = html.toJS;
      final clicks = <String, int>{};

      tester.pumpComponent(
        .apply(
          target: const .descendantWith(classes: {'target'}),
          classes: 'applied',
          events: {
            'click': (e) => clicks.update(
              (e.target! as HTMLElement).localName,
              (c) => c + 1,
              ifAbsent: () => 1,
            ),
          },
          child: SlottedChildView(
            slots: [
              ChildSlot.fromQuery('main', child: button(classes: 'target', [.text('Hydrated')])),
            ],
          ),
        ),
      );

      void expectAppliedOnce() {
        final staticElement = window.document.querySelector('p')! as HTMLElement;
        final btn = window.document.querySelector('button')! as HTMLElement;
        expect(staticElement.className, 'target applied');
        expect(btn.className, 'target applied');
        expect(btn.textContent, 'Hydrated');

        final before = {...clicks};
        staticElement.click();
        btn.click();
        expect(clicks['p'], (before['p'] ?? 0) + 1);
        expect(clicks['button'], (before['button'] ?? 0) + 1);
      }

      expectAppliedOnce();

      final newBody = window.document.createElement('body') as HTMLBodyElement;
      newBody.innerHTML = html.toJS;
      final rootElement = tester.binding.rootElement!;
      (rootElement.renderObject as RootDomRenderObject).setRootNode(newBody);
      rootElement.owner.performReload(rootElement);
      window.document.body!.replaceWith(newBody);
      await pumpEventQueue();

      expectAppliedOnce();
    });

    testClient('resolves a query slot using applied values after a reload', (tester) async {
      const html = '<section><main>Server</main></section>';
      window.document.body!.innerHTML = html.toJS;

      tester.pumpComponent(
        .apply(
          target: const .descendantWith(tag: 'main'),
          classes: 'mount-target',
          child: SlottedChildView(
            slots: [
              ChildSlot.fromQuery('.mount-target', child: span([.text('Hydrated')])),
            ],
          ),
        ),
      );

      expect(window.document.querySelector('main')!.textContent, 'Hydrated');

      final newBody = window.document.createElement('body') as HTMLBodyElement;
      newBody.innerHTML = html.toJS;
      final rootElement = tester.binding.rootElement!;
      (rootElement.renderObject as RootDomRenderObject).setRootNode(newBody);
      rootElement.owner.performReload(rootElement);
      window.document.body!.replaceWith(newBody);
      await pumpEventQueue();

      final mainElement = window.document.querySelector('main')!;
      expect(mainElement.textContent, 'Hydrated');
      expect(mainElement.className, 'mount-target');
    });

    testClient('does not apply params to elements owned by a slot nested in a static element', (tester) async {
      window.document.body!.innerHTML = '<section><!--start--><button>Static</button><!--end--></section>'.toJS;
      final section = window.document.body!.firstChild!;
      final start = section.firstChild!;
      final end = section.lastChild!;
      var clicks = 0;

      tester.pumpComponent(
        .apply(
          target: ApplyTarget.descendantWith(tag: 'button'),
          classes: 'applied',
          events: {'click': (_) => clicks++},
          child: SlottedChildView(
            slots: [
              ChildSlot.between(start: start, end: end, child: button([.text('Hydrated')])),
            ],
          ),
        ),
      );

      final btn = window.document.querySelector('button')! as HTMLElement;
      expect(btn.textContent, 'Hydrated');
      expect(btn.classList.contains('applied'), isTrue);
      btn.click();
      expect(clicks, 1);

      // The slot owns the button, so unmounting the view must not reset its params,
      // and only the slot's child removes its listener.
      tester.binding.detachRootComponent();
      expect(btn.classList.contains('applied'), isTrue);
      btn.click();
      expect(clicks, 1);
    });

    testClient('does not apply params to elements owned by a query slot', (tester) async {
      window.document.body!.innerHTML = '<section><main><button>Static</button></main></section>'.toJS;
      var clicks = 0;

      tester.pumpComponent(
        .apply(
          target: ApplyTarget.descendantWith(tag: 'button'),
          classes: 'applied',
          events: {'click': (_) => clicks++},
          child: SlottedChildView(
            slots: [
              ChildSlot.fromQuery('main', child: button([.text('Hydrated')])),
            ],
          ),
        ),
      );

      final btn = window.document.querySelector('button')! as HTMLElement;
      expect(btn.textContent, 'Hydrated');
      expect(btn.classList.contains('applied'), isTrue);
      btn.click();
      expect(clicks, 1);

      tester.binding.detachRootComponent();
      btn.click();
      expect(clicks, 1);
    });

    testClient('still applies params to static elements around nested slots', (tester) async {
      window.document.body!.innerHTML =
          '<section><p>Static</p><!--start--><p>Slotted</p><!--end--></section><p id="after">After</p>'.toJS;
      final section = window.document.body!.firstChild!;
      final start = section.childNodes.item(1)!;
      final end = section.lastChild!;

      tester.pumpComponent(
        .apply(
          target: ApplyTarget.descendantWith(tag: 'p'),
          classes: 'applied',
          child: SlottedChildView(
            slots: [
              ChildSlot.between(
                start: start,
                end: end,
                child: p(classes: 'own', [.text('Slotted')]),
              ),
            ],
          ),
        ),
      );

      final paragraphs = window.document.querySelectorAll('p');
      expect(paragraphs.length, 3);
      for (var i = 0; i < paragraphs.length; i++) {
        expect((paragraphs.item(i)! as HTMLElement).classList.contains('applied'), isTrue);
      }
      expect((paragraphs.item(1)! as HTMLElement).className, 'own applied');
    });
  });
}
