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

    testClient('hands applied params over to a slot added after the first build', (tester) async {
      window.document.body!.innerHTML = '<!--start--><button>Static</button><!--end-->'.toJS;
      final start = window.document.body!.firstChild!;
      final end = window.document.body!.lastChild!;
      var slotted = false;
      late void Function(void Function() cb) setState;
      var clicks = 0;

      tester.pumpComponent(
        .apply(
          target: const .descendantWith(tag: 'button'),
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

      // The slot's child hydrates the same button and now applies the params instead of the view,
      // so the handler still fires only once per click.
      expect(window.document.querySelector('button'), equals(btn));
      expect(btn.textContent, 'Hydrated');
      expect(btn.classList.contains('applied'), isTrue);
      expect(btn.getAttribute('data-applied'), 'true');
      btn.click();
      expect(clicks, 2);
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
                        if (slotted) ChildSlot.fromQuery(query, child: span([.text(text)])),
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
        // The slot owns the children of `main`, not `main` itself, so the view keeps its values.
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

      // The class and the slot whose query depends on it are added together,
      // so the view must apply the new params before it resolves the query.
      setState(() => enabled = true);
      await pumpEventQueue();

      expect(window.document.querySelector('main'), equals(mainElement));
      expect(mainElement.className, 'mount-target');
      expect(mainElement.textContent, 'Hydrated');
    });

    for (final querySlot in [false, true]) {
      for (final nestedView in [false, true]) {
        testClient(
          'takes over the elements of a removed ${querySlot ? 'query' : 'range'} slot '
          'from ${nestedView ? 'a nested view' : 'a hydrated child'}',
          (tester) async {
            window.document.body!.innerHTML =
                '<section><main><!--start-->'
                        '<button class="original" data-own="true">Static</button>'
                        '<!--end--></main></section>'
                    .toJS;
            final mainElement = window.document.querySelector('main')!;
            final btn = mainElement.querySelector('button')! as HTMLElement;
            var slotted = true;
            var enabled = true;
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
                    styles: enabled ? const Styles(color: Colors.red) : null,
                    attributes: enabled ? const {'data-applied': 'true'} : null,
                    events: enabled ? {'click': (_) => clicks++} : null,
                    child: StatefulBuilder(
                      builder: (context, set) {
                        setSlot = set;
                        final child = nestedView
                            ? SlottedChildView(slots: const [])
                            : button(classes: 'original', attributes: const {'data-own': 'true'}, [.text('Hydrated')]);
                        return SlottedChildView(
                          slots: [
                            if (slotted)
                              if (querySlot)
                                ChildSlot.fromQuery('main', child: child)
                              else
                                ChildSlot.between(
                                  start: mainElement.firstChild!,
                                  end: mainElement.lastChild!,
                                  child: child,
                                ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            );

            void expectApplied() {
              expect(btn.className, 'original applied');
              expect(btn.style.color, 'red');
              expect(btn.getAttribute('data-applied'), 'true');
              expect(btn.getAttribute('data-own'), 'true');
              final before = clicks;
              btn.click();
              expect(clicks, before + 1);
            }

            void expectOriginal() {
              expect(btn.className, 'original');
              expect(btn.hasAttribute('style'), isFalse);
              expect(btn.hasAttribute('data-applied'), isFalse);
              expect(btn.getAttribute('data-own'), 'true');
              final before = clicks;
              btn.click();
              expect(clicks, before);
            }

            expectApplied();

            // The slot's DOM stays in place, and the view applies the params to it instead.
            setSlot(() => slotted = false);
            await pumpEventQueue();
            expect(mainElement.querySelector('button'), equals(btn));
            expectApplied();

            // The view only removes values it applied itself,
            // so this verifies it took over the values from the slot's child.
            setParams(() => enabled = false);
            await pumpEventQueue();
            expectOriginal();

            setParams(() => enabled = true);
            await pumpEventQueue();
            expectApplied();

            tester.binding.detachRootComponent();
            expectOriginal();
          },
        );
      }
    }

    testClient('takes over the elements of a slot nested in a removed slot', (tester) async {
      window.document.body!.innerHTML =
          '<section><main><article><div><button>Static</button></div></article></main></section>'.toJS;
      final btn = window.document.querySelector('button')! as HTMLElement;
      var slotted = true;
      var enabled = true;
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
                        ChildSlot.fromQuery(
                          'main',
                          child: SlottedChildView(
                            slots: [
                              ChildSlot.fromQuery('div', child: button([.text('Hydrated')])),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      );

      expect(btn.className, 'applied');
      btn.click();
      expect(clicks, 1);

      // Removing the outer slot also unmounts the nested slot, which releases the button,
      // and the outer view takes it over once both have unmounted.
      setSlot(() => slotted = false);
      await pumpEventQueue();
      expect(btn.textContent, 'Hydrated');
      expect(btn.className, 'applied');
      btn.click();
      expect(clicks, 2);

      setParams(() => enabled = false);
      await pumpEventQueue();
      expect(btn.hasAttribute('class'), isFalse);
      btn.click();
      expect(clicks, 2);
    });

    for (final nestedView in [false, true]) {
      for (final afterRemovedSlot in [false, true]) {
        testClient(
          'hands the elements of a replaced slot to ${nestedView ? 'a nested view' : 'a hydrated child'} '
          'of the new slot${afterRemovedSlot ? ' after another removed slot' : ''}',
          (tester) async {
            window.document.body!.innerHTML =
                '<section><aside><b>Aside</b></aside><main><button>Static</button></main></section>'.toJS;
            final btn = window.document.querySelector('button')! as HTMLElement;
            var version = 1;
            var enabled = true;
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
                            // Removing a slot before the replaced one means the new slot isn't
                            // in the same position as the slot it replaces.
                            if (afterRemovedSlot && version == 1)
                              ChildSlot.fromQuery('aside', key: const ValueKey('aside'), child: b([.text('Aside')])),
                            // A new key replaces the slot with one that hydrates the same nodes.
                            // Its query matches an inherited class, which the replaced slot's child
                            // released, so the view must apply it again before resolving the query.
                            ChildSlot.fromQuery(
                              'main:has(button.applied)',
                              key: ValueKey(version),
                              child: version == 2 && nestedView
                                  ? SlottedChildView(slots: const [])
                                  : button([.text('Version $version')]),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            );

            expect(btn.className, 'applied');

            setSlot(() => version = 2);
            await pumpEventQueue();

            // The replaced slot's child released the button before the new slot took it over.
            expect(window.document.querySelector('button'), equals(btn));
            expect(btn.textContent, nestedView ? 'Version 1' : 'Version 2');
            expect(btn.className, 'applied');
            btn.click();
            expect(clicks, 1);

            // The new slot's child owns the values on the button,
            // rather than treating the values the replaced child added as original ones.
            setParams(() => enabled = false);
            await pumpEventQueue();
            expect(btn.hasAttribute('class'), isFalse);
            btn.click();
            expect(clicks, 1);
          },
        );
      }
    }

    testClient('keeps the params of an element moved out of a removed slot with a global key', (tester) async {
      window.document.body!.innerHTML = '<section><main><button>Static</button></main></section>'.toJS;
      final buttonKey = GlobalKey();
      var moved = false;
      var ownEvents = 0;
      var outerClicks = 0;
      var movedClicks = 0;
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            final movable = button(key: buttonKey, events: {'own': (_) => ownEvents++}, [.text('Hydrated')]);
            // The slot comes first, so it's deactivated before the button is moved out of it.
            return Component.fragment([
              .apply(
                target: const .descendantWith(tag: 'button'),
                classes: 'outer',
                events: {'click': (_) => outerClicks++},
                child: SlottedChildView(
                  slots: [
                    if (!moved) ChildSlot.fromQuery('main', child: movable),
                  ],
                ),
              ),
              .apply(
                target: const .descendantWith(tag: 'button'),
                classes: 'moved',
                events: {'click': (_) => movedClicks++},
                child: div(id: 'destination', [if (moved) movable]),
              ),
            ]);
          },
        ),
      );

      final btn = window.document.querySelector('button')! as HTMLElement;
      expect(btn.className, 'outer');

      setState(() => moved = true);
      await pumpEventQueue();

      // The button released its values and listeners when its slot was removed,
      // and renders them again for its new parent. The view only takes over
      // the slot's remaining nodes once the slot unmounts, after the button moved.
      expect(window.document.querySelector('#destination > button'), equals(btn));
      expect(btn.className, 'moved');
      btn.click();
      btn.dispatchEvent(Event('own'));
      expect(ownEvents, 1);
      expect(movedClicks, 1);
      expect(outerClicks, 0);
    });

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
                    ChildSlot.fromQuery(
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

      // Releasing the field removes the listener and inherited values of its child,
      // but not the value entered into it.
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
            return Component.fragment([
              SlottedChildView(
                slots: [
                  if (!moved) ChildSlot.fromQuery('main', child: movable),
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
            return Component.fragment([
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
                        ChildSlot.fromQuery(
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

      // Remove the slot while the view's DOM is detached, then attach it again.
      section.remove();
      setSlot(() => slotted = false);
      await pumpEventQueue();
      window.document.body!.append(section);

      // The listeners of the removed child don't fire anymore,
      // and the view applies its params in place of the child's.
      expect(btn.className, 'applied');
      btn.dispatchEvent(Event('own'));
      expect(ownEvents, 0);
      btn.click();
      expect(clicks, 1);

      // The view owns the inherited values, rather than treating them as original values.
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

      // The removed slot's DOM stays in place and the view now owns the leftover button,
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

      // Each slot's child applies the params to its own button.
      // If the view also applied them to the second button, it would fire twice.
      final buttons = window.document.querySelectorAll('button');
      expect(buttons.length, 2);
      (buttons.item(0)! as HTMLElement).click();
      expect(clicks, 1);
      (buttons.item(1)! as HTMLElement).click();
      expect(clicks, 2);
    });

    for (final deferred in [false, true]) {
      testClient('resolves a query using inherited params in ${deferred ? 'a deferred' : 'an initial'} nested view', (
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

        // The nested view owns `main` and applied its class before resolving the query.
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
              // The `original` class, background color, and `data-original` attribute
              // are already on the button, so they must never be overwritten or removed.
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

        // The outer view releases the button before the nested view hydrates it,
        // so only the nested view applies the params, and the handler fires once.
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

    for (final querySlot in [false, true]) {
      testClient('releases only the elements in a new ${querySlot ? 'query' : 'range'} slot to a nested view', (
        tester,
      ) async {
        window.document.body!.innerHTML =
            '<section id="section" class="target"><p id="before" class="target">Before</p><!--start-->'
                    '<div id="container" class="target">'
                    '<button id="first" class="target">First</button><button id="second" class="target">Second</button>'
                    '</div><!--end--><p id="after" class="target">After</p></section>'
                .toJS;
        final container = window.document.getElementById('container')!;
        const nestedViewKey = ValueKey('nested-view');
        var slotted = false;
        late void Function(void Function() cb) setSlot;
        // Count a non-bubbling event per element, so each count reflects only that element's listeners.
        final pings = <String, int>{};

        tester.pumpComponent(
          .apply(
            target: const .descendantWith(classes: {'target'}),
            classes: 'applied',
            events: {
              'ping': (e) => pings.update((e.currentTarget! as HTMLElement).id, (c) => c + 1, ifAbsent: () => 1),
            },
            child: StatefulBuilder(
              builder: (context, set) {
                setSlot = set;
                final nestedView = SlottedChildView(key: nestedViewKey, slots: const []);
                return SlottedChildView(
                  slots: [
                    if (slotted)
                      if (querySlot)
                        // Owns the buttons, but not the container itself.
                        ChildSlot.fromQuery('#container', child: nestedView)
                      else
                        // Owns the container and the buttons inside it.
                        ChildSlot.between(
                          start: container.previousSibling!,
                          end: container.nextSibling!,
                          child: nestedView,
                        ),
                  ],
                );
              },
            ),
          ),
        );

        const ids = ['section', 'before', 'container', 'first', 'second', 'after'];

        void expectAppliedOnce() {
          for (final id in ids) {
            final element = window.document.getElementById(id)!;
            expect(element.className, 'target applied', reason: id);
            element.dispatchEvent(Event('ping'));
          }
          expect(pings, {for (final id in ids) id: 1});
          pings.clear();
        }

        expectAppliedOnce();

        setSlot(() => slotted = true);
        await pumpEventQueue();

        // Each element still has the params applied by exactly one owner,
        // whether that's the outer view or the nested view in the slot.
        expect(find.byKey(nestedViewKey), findsOneComponent);
        expectAppliedOnce();

        tester.binding.detachRootComponent();
        for (final id in ids) {
          final element = window.document.getElementById(id)!;
          expect(element.className, 'target', reason: id);
          element.dispatchEvent(Event('ping'));
        }
        expect(pings, isEmpty);
      });
    }

    testClient('prefers inner params over released outer params when adding a slot with a nested view', (tester) async {
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

      // Params never overwrite existing values,
      // so the outer view must remove its color before
      // the nested view applies the closer, inner color.
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

        staticElement.click();
        btn.click();
        expect(clicks, {'p': 1, 'button': 1});
        clicks.clear();
      }

      expectAppliedOnce();

      // The reload replaces the nodes,
      // so the view must apply its params to the new static nodes
      // and again leave the button to the slot's child.
      await _reload(tester, html);

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

      await _reload(tester, html);

      final mainElement = window.document.querySelector('main')!;
      expect(mainElement.textContent, 'Hydrated');
      expect(mainElement.className, 'mount-target');
    });

    for (final querySlot in [false, true]) {
      testClient(
        'leaves the elements of a '
        'nested ${querySlot ? 'query' : 'range'} slot to the slot\'s child',
        (tester) async {
          window.document.body!.innerHTML =
              '<section><main><!--start--><button>Static</button><!--end--></main></section>'.toJS;
          final mainElement = window.document.querySelector('main')!;
          var clicks = 0;

          tester.pumpComponent(
            .apply(
              target: const .descendantWith(tag: 'button'),
              classes: 'applied',
              events: {'click': (_) => clicks++},
              child: SlottedChildView(
                slots: [
                  if (querySlot)
                    ChildSlot.fromQuery('main', child: button([.text('Hydrated')]))
                  else
                    ChildSlot.between(
                      start: mainElement.firstChild!,
                      end: mainElement.lastChild!,
                      child: button([.text('Hydrated')]),
                    ),
                ],
              ),
            ),
          );

          // The slot's child applies the params to its button, and the view doesn't add them again.
          final btn = window.document.querySelector('button')! as HTMLElement;
          expect(btn.textContent, 'Hydrated');
          expect(btn.className, 'applied');
          btn.click();
          expect(clicks, 1);

          // The slot's child leaves its DOM in place when it unmounts,
          // but without the values and listeners it added for the params.
          tester.binding.detachRootComponent();
          expect(btn.textContent, 'Hydrated');
          expect(btn.hasAttribute('class'), isFalse);
          btn.click();
          expect(clicks, 1);
        },
      );
    }

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
              ChildSlot.between(
                start: start,
                end: end,
                child: p(classes: 'own', [.text('Slotted')]),
              ),
            ],
          ),
        ),
      );

      // The view applies the params to the paragraphs before and after the slot,
      // while the slot's child applies them to its own paragraph.
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
