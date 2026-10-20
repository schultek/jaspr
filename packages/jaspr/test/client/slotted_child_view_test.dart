@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:jaspr/client.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/src/client/dom_render_object.dart' show RootDomRenderObject;
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
            .between(start: start, end: end, child: span([.text('Slotted')])),
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

      // Check that the target element parameters are reset,
      // without leaving behind attributes that the element didn't have before.
      expect(pElement.hasAttribute('id'), isFalse);
      expect(pElement.hasAttribute('class'), isFalse);
      expect(pElement.hasAttribute('style'), isFalse);
      expect(pElement.hasAttribute('data-test'), isFalse);

      // Trigger click again - should not increment clicked
      pElement.click();
      expect(clicked, 1);
    });

    testClient('removes the listeners of a replaced slot from the nodes left in place', (tester) async {
      window.document.body!.innerHTML = '<!--start--><button>Click</button><!--end-->'.toJS;
      final start = window.document.body!.firstChild!;
      final end = window.document.body!.lastChild!;
      var slotKey = 0;
      late void Function(void Function() cb) setState;
      var clicks = 0;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return SlottedChildView(
              slots: [
                .between(
                  key: ValueKey(slotKey),
                  start: start,
                  end: end,
                  child: button(events: {'click': (_) => clicks++}, [.text('Click')]),
                ),
              ],
            );
          },
        ),
      );

      final btn = window.document.querySelector('button')! as HTMLElement;
      btn.click();
      expect(clicks, 1);

      // The new slot's child hydrates the same button,
      // so the listener of the replaced slot's child must be removed.
      setState(() => slotKey++);
      await pumpEventQueue();
      expect(window.document.querySelector('button'), equals(btn));

      btn.click();
      expect(clicks, 2);
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
              styles: const Styles(color: Colors.red),
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

      // The button isn't a direct child of the view, so it no longer matches.
      setState(() => descendants = false);
      await pumpEventQueue();

      // Attributes that the params added are removed rather than left empty.
      expect(btn.hasAttribute('id'), isFalse);
      expect(btn.className, 'original');
      expect(btn.hasAttribute('style'), isFalse);
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

    for (final query in ['#mount-target', '.mount-target', '[data-target="true"]']) {
      testClient('resolves a new query slot for $query using applied values', (tester) async {
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
                        if (slotted) .fromQuery(query, child: span([.text(text)])),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        );

        // Only the view's applied values make the query match.
        expect(window.document.querySelector(query), equals(mainElement));

        setSlot(() => slotted = true);
        await pumpEventQueue();
        expect(mainElement.textContent, 'Hydrated');
        // The slot only renders into `main`, so the view's values stay on `main` itself.
        expect(window.document.querySelector(query), equals(mainElement));

        // An existing slot keeps its target even when its query stops matching.
        setParams(() => enabled = false);
        await pumpEventQueue();
        expect(window.document.querySelector(query), isNull);

        setSlot(() => text = 'Updated');
        await pumpEventQueue();
        expect(window.document.querySelector('main'), equals(mainElement));
        expect(mainElement.textContent, 'Updated');
      });

      testClient('resolves a new query slot for $query using values changed in the same build', (tester) async {
        window.document.body!.innerHTML = '<section><main>Fallback</main></section>'.toJS;
        final mainElement = window.document.querySelector('main')! as HTMLElement;
        var enabled = false;
        var clicks = 0;
        late void Function(void Function() cb) setState;

        tester.pumpComponent(
          StatefulBuilder(
            builder: (context, set) {
              setState = set;
              return .apply(
                target: const .descendantWith(tag: 'main'),
                id: enabled ? 'mount-target' : null,
                classes: enabled ? 'mount-target' : null,
                attributes: enabled ? const {'data-target': 'true'} : null,
                events: enabled ? {'click': (_) => clicks++} : null,
                child: SlottedChildView(
                  slots: [
                    if (enabled) .fromQuery(query, child: span([.text('Hydrated')])),
                  ],
                ),
              );
            },
          ),
        );

        expect(window.document.querySelector(query), isNull);
        expect(mainElement.textContent, 'Fallback');

        // Add the matching values and the slot together.
        // The values must be applied before the slot
        // resolves its query and mounts its child.
        setState(() => enabled = true);
        await pumpEventQueue();

        expect(window.document.querySelector(query), equals(mainElement));
        expect(mainElement.textContent, 'Hydrated');

        // The view applies the values again once its slots are built,
        // which must not leave a second listener behind.
        mainElement.click();
        expect(clicks, 1);

        // Removing the values cleans up after both times they were applied.
        setState(() => enabled = false);
        await pumpEventQueue();

        expect(mainElement.hasAttribute('id'), isFalse);
        expect(mainElement.hasAttribute('class'), isFalse);
        expect(mainElement.hasAttribute('data-target'), isFalse);
        mainElement.click();
        expect(clicks, 1);
      });
    }

    testClient('keeps the state of form elements in a removed slot', (tester) async {
      window.document.body!.innerHTML = '<section><main><input value="Initial"></main></section>'.toJS;
      final field = window.document.querySelector('input')! as HTMLInputElement;
      var slotted = true;
      var inputs = 0;
      late void Function(void Function() cb) setSlot;

      tester.pumpComponent(
        .apply(
          target: const .descendantWith(tag: 'input'),
          classes: 'applied',
          child: StatefulBuilder(
            builder: (context, set) {
              setSlot = set;
              return SlottedChildView(
                slots: [
                  if (slotted)
                    .fromQuery(
                      'main',
                      child: input<String>(value: 'Initial', onInput: (_) => inputs++),
                    ),
                ],
              );
            },
          ),
        ),
      );

      field.value = 'Edited';
      field.dispatchEvent(Event('input'));
      expect(inputs, 1);

      setSlot(() => slotted = false);
      await pumpEventQueue();

      // Removing the slot removes the listener of its child,
      // but not the value entered into the field or the view's applied class.
      expect(window.document.querySelector('input'), equals(field));
      expect(field.value, 'Edited');
      expect(field.className, 'applied');
      field.dispatchEvent(Event('input'));
      expect(inputs, 1);
    });

    testClient('keeps the state of a form element moved out of a removed slot with a global key', (tester) async {
      window.document.body!.innerHTML = '<section><main><input value="Initial"></main></section>'.toJS;
      final field = window.document.querySelector('input')! as HTMLInputElement;
      var moved = false;
      var inputs = 0;
      late void Function(void Function() cb) setState;
      // The same component is moved, so the field doesn't need to render again for its new parent.
      final movable = input<String>(key: GlobalKey(), value: 'Initial', onInput: (_) => inputs++);

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .fragment([
              SlottedChildView(
                slots: [
                  if (!moved) .fromQuery('main', child: movable),
                ],
              ),
              div(id: 'destination', [if (moved) movable]),
            ]);
          },
        ),
      );

      field.value = 'Edited';
      setState(() => moved = true);
      await pumpEventQueue();

      expect(window.document.querySelector('#destination > input'), equals(field));
      expect(field.value, 'Edited');
      field.dispatchEvent(Event('input'));
      expect(inputs, 1);
    });

    testClient('applies params after being moved into them with a global key', (tester) async {
      window.document.body!.innerHTML = '<div id="source"><p class="static">Static</p></div>'.toJS;
      final paragraph = window.document.querySelector('p')!;
      var moved = false;
      late void Function(void Function() cb) setState;
      final movable = SlottedChildView.withNodes(key: GlobalKey(), nodes: [paragraph], slots: const []);

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .fragment([
              div(id: 'source', [if (!moved) movable]),
              .apply(
                target: const .descendantWith(tag: 'p'),
                classes: 'applied',
                child: div(id: 'destination', [if (moved) movable]),
              ),
            ]);
          },
        ),
      );

      expect(paragraph.className, 'static');

      // The view had no inherited params before, so only the new ones make it render again.
      setState(() => moved = true);
      await pumpEventQueue();
      expect(window.document.querySelector('#destination > p'), equals(paragraph));
      expect(paragraph.className, 'static applied');
    });

    testClient('releases the elements of a slot removed while detached from the document', (tester) async {
      window.document.body!.innerHTML = '<section><main><button>Static</button></main></section>'.toJS;
      final section = window.document.querySelector('section')!;
      final btn = window.document.querySelector('button')! as HTMLElement;
      var slotted = true;
      var enabled = true;
      var ownEvents = 0;
      var clicks = 0;
      late void Function(void Function() cb) setParams;
      late void Function(void Function() cb) setSlot;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setParams = set;
            return .apply(
              target: const .descendantWith(tag: 'button'),
              classes: enabled ? 'applied' : null,
              events: enabled ? {'click': (_) => clicks++} : null,
              child: StatefulBuilder(
                builder: (context, set) {
                  setSlot = set;
                  return SlottedChildView(
                    slots: [
                      if (slotted)
                        .fromQuery(
                          'main',
                          child: button(events: {'own': (_) => ownEvents++}, [.text('Hydrated')]),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      );

      // Confirm the slot's child installed its listener before testing cleanup.
      btn.dispatchEvent(Event('own'));
      expect(ownEvents, 1);

      // Remove the slot while the view's DOM is detached, then attach it again.
      section.remove();
      setSlot(() => slotted = false);
      await pumpEventQueue();
      window.document.body!.append(section);

      // The listeners of the removed child don't fire anymore,
      // while the view's params stay applied.
      expect(btn.className, 'applied');
      btn.dispatchEvent(Event('own'));
      expect(ownEvents, 1);
      btn.click();
      expect(clicks, 1);

      // The view removes the values it applied, rather than treating them as original values.
      setParams(() => enabled = false);
      await pumpEventQueue();
      expect(btn.hasAttribute('class'), isFalse);
      btn.click();
      expect(clicks, 1);
    });

    testClient('removes the listeners added by the child of a removed slot', (tester) async {
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
                    .between(
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

      // The removed slot's DOM stays in place and
      // the view now applies its params to the leftover button,
      // so only the view's listener remains and the handler fires once.
      expect(window.document.querySelector('button'), equals(btn));
      btn.click();
      expect(clicks, 2);

      tester.binding.detachRootComponent();
      btn.click();
      expect(clicks, 2);
    });

    testClient('does not own the elements of adjacent range slots that share an anchor', (tester) async {
      window.document.body!.innerHTML = '<!--a--><button>First</button><!--b--><button>Second</button><!--c-->'.toJS;
      final anchors = window.document.body!.childNodes;
      var clicks = 0;

      tester.pumpComponent(
        .apply(
          target: const .descendantWith(tag: 'button'),
          events: {'click': (_) => clicks++},
          child: SlottedChildView(
            slots: [
              .between(
                start: anchors.item(0)!,
                end: anchors.item(2)!,
                child: button([.text('First')]),
              ),
              .between(
                start: anchors.item(2)!,
                end: anchors.item(4)!,
                child: button([.text('Second')]),
              ),
            ],
          ),
        ),
      );

      // Each slot's child applies the params to its own button.
      // If the view also applied them to the second button, it would fire twice.
      final buttons = window.document.querySelectorAll('button');
      expect(buttons.length, 2);
      (buttons.item(0)! as HTMLElement).click();
      expect(clicks, 1);
      (buttons.item(1)! as HTMLElement).click();
      expect(clicks, 2);
    });

    testClient('resolves a query using inherited params in an initial nested view', (tester) async {
      window.document.body!.innerHTML = '<!--start--><section><main>Fallback</main></section><!--end-->'.toJS;
      final start = window.document.body!.firstChild!;
      final end = window.document.body!.lastChild!;
      final mainElement = window.document.querySelector('main')!;

      tester.pumpComponent(
        .apply(
          target: const .descendantWith(tag: 'main'),
          classes: 'mount-target',
          child: SlottedChildView(
            slots: [
              .between(
                start: start,
                end: end,
                child: SlottedChildView(
                  slots: [
                    .fromQuery('.mount-target', child: span([.text('Hydrated')])),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      // The nested view applied its class to `main` before resolving the query.
      expect(window.document.querySelector('main'), equals(mainElement));
      expect(mainElement.textContent, 'Hydrated');
      expect(mainElement.className, 'mount-target');

      tester.binding.detachRootComponent();
      expect(mainElement.hasAttribute('class'), isFalse);
    });

    testClient('resolves a new query slot in a nested view using values changed in the same build', (tester) async {
      window.document.body!.innerHTML = '<!--start--><section><main>Fallback</main></section><!--end-->'.toJS;
      final start = window.document.body!.firstChild!;
      final end = window.document.body!.lastChild!;
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
                  .between(
                    start: start,
                    end: end,
                    child: SlottedChildView(
                      slots: [
                        if (enabled) .fromQuery('.mount-target', child: span([.text('Hydrated')])),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      expect(mainElement.textContent, 'Fallback');

      // The outer view leaves the range slot's nodes to the nested view,
      // which receives the new class through the outer view and
      // must apply it before resolving its query.
      setState(() => enabled = true);
      await pumpEventQueue();

      expect(mainElement.textContent, 'Hydrated');
      expect(mainElement.className, 'mount-target');
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
              .fromQuery('.mount-target', child: span([.text('Hydrated')])),
            ],
          ),
        ),
      );

      expect(window.document.querySelector('main')!.textContent, 'Hydrated');

      await _reload(tester, html);

      final mainElement = window.document.querySelector('main')!;
      expect(mainElement.textContent, 'Hydrated');
      expect(mainElement.className, 'mount-target');
    });

    testClient('applies params to the static elements around a nested range slot', (tester) async {
      window.document.body!.innerHTML =
          '<section><p>Static</p><!--start--><p>Slotted</p><!--end--></section><p id="after">After</p>'.toJS;
      final section = window.document.body!.firstChild!;
      final start = section.childNodes.item(1)!;
      final end = section.lastChild!;

      tester.pumpComponent(
        .apply(
          target: const .descendantWith(tag: 'p'),
          classes: 'applied',
          child: SlottedChildView(
            slots: [
              .between(
                start: start,
                end: end,
                child: p(classes: 'own', [.text('Slotted')]),
              ),
            ],
          ),
        ),
      );

      // The static paragraphs before and after the slot receive the applied class,
      // and the slotted paragraph has both its own and the applied class.
      final paragraphs = window.document.querySelectorAll('p');
      expect(
        [for (var i = 0; i < paragraphs.length; i++) (paragraphs.item(i)! as HTMLElement).className],
        ['applied', 'own applied', 'applied'],
      );
    });
  });
}

/// Reloads the app with fresh server-rendered [html],
/// following the same sequence as the client's reload handler.
Future<void> _reload(ClientTester tester, String html) async {
  final newBody = window.document.createElement('body') as HTMLBodyElement;
  newBody.innerHTML = html.toJS;
  final rootElement = tester.binding.rootElement!;
  (rootElement.renderObject as RootDomRenderObject).setRootNode(newBody);
  rootElement.owner.performReload(rootElement);
  window.document.body!.replaceWith(newBody);
  await pumpEventQueue();
}
