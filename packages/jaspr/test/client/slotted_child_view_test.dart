@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

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

    testClient('preserves child state when keyed slots change order', (tester) async {
      window.document.body!.innerHTML = '<section><header></header><footer></footer></section>'.toJS;
      final states = <String, State<StatefulComponent>>{};
      var order = ['header', 'footer'];
      late StateSetter rebuild;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return .apply(
              target: const .descendantWith(tag: 'span'),
              classes: 'applied',
              child: SlottedChildView(
                slots: [
                  for (final tag in order)
                    .fromQuery(
                      tag,
                      key: ValueKey(tag),
                      child: StatefulBuilder(
                        builder: (context, _) {
                          states[tag] = (context as StatefulElement).state;
                          return span([.text(tag)]);
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );

      final headerState = states['header']!;
      final footerState = states['footer']!;
      states.clear();
      rebuild(() => order = ['footer', 'header']);
      await pumpEventQueue();

      expect(states['header'], same(headerState));
      expect(states['footer'], same(footerState));
      expect(window.document.querySelector('header > span.applied')!.textContent, 'header');
      expect(window.document.querySelector('footer > span.applied')!.textContent, 'footer');
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

    testClient('direct child applies follow the DOM parent through nested slots', (tester) async {
      window.document.body!.innerHTML = '<section><main><!--start--><button></button><!--end--></main></section>'.toJS;
      final main = window.document.querySelector('main')!;
      final original = main.querySelector('button')!;

      tester.pumpComponent(
        .apply(
          target: const .childWith(tag: 'button'),
          classes: 'outer-child',
          child: .apply(
            target: const .descendantWith(tag: 'button'),
            attributes: const {'data-descendant': 'true'},
            child: SlottedChildView(
              slots: [
                .fromQuery(
                  'main',
                  child: .apply(
                    target: const .childWith(tag: 'button'),
                    classes: 'inner-child',
                    child: SlottedChildView(
                      slots: [.between(start: main.firstChild!, end: main.lastChild!, child: button([]))],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(main.querySelector('button'), equals(original));
      expect(original.className, 'inner-child');
      expect(original.getAttribute('data-descendant'), 'true');
    });

    for (final value in ['123target', 'a:b', 'a.b', 'a/b']) {
      for (final byId in [true, false]) {
        testClient('matches descendant ${byId ? 'IDs' : 'classes'} literally: $value', (tester) async {
          window.document.body!.innerHTML =
              '<section><button>Target</button><button id="a" class="a b">Other</button></section>'.toJS;
          final buttons = window.document.querySelectorAll('button');
          final target = buttons.item(0)! as HTMLElement;
          final other = buttons.item(1)! as HTMLElement;
          target.id = value;
          target.className = value;

          tester.pumpComponent(
            .apply(
              target: byId ? .descendantWith(id: value) : .descendantWith(classes: {value}),
              attributes: const {'data-applied': 'true'},
              child: SlottedChildView(slots: const []),
            ),
          );

          expect(target.getAttribute('data-applied'), 'true');
          // In particular, `a.b` must not select an ID plus a class, or two classes.
          expect(other.hasAttribute('data-applied'), isFalse);
        });
      }
    }

    for (final value in ['123target', 'a:b', 'a.b', 'a/b']) {
      for (final byId in [true, false]) {
        testClient('matches child ${byId ? 'IDs' : 'classes'} literally: $value', (tester) async {
          window.document.body!.innerHTML = '<button>Target</button><button id="a" class="a b">Other</button>'.toJS;
          final buttons = window.document.querySelectorAll('button');
          final target = buttons.item(0)! as HTMLElement;
          final other = buttons.item(1)! as HTMLElement;
          target.id = value;
          target.className = value;

          tester.pumpComponent(
            .apply(
              target: byId ? .childWith(id: value) : .childWith(classes: {value}),
              attributes: const {'data-applied': 'true'},
              child: SlottedChildView(slots: const []),
            ),
          );

          expect(target.getAttribute('data-applied'), 'true');
          // In particular, `a.b` must not select an ID plus a class, or two classes.
          expect(other.hasAttribute('data-applied'), isFalse);
        });
      }
    }

    testClient('combines literal descendant target IDs and classes with the tag', (tester) async {
      window.document.body!.innerHTML =
          '<section>'
                  '<button id="a:b" class="sm:hover w-1/2">Target</button>'
                  '<span id="a:b" class="sm:hover w-1/2">Wrong tag</span>'
                  '<button id="other" class="sm:hover w-1/2">Wrong ID</button>'
                  '<button id="a:b" class="sm:hover">Missing class</button>'
                  '</section>'
              .toJS;

      tester.pumpComponent(
        .apply(
          target: const .descendantWith(tag: 'button', id: 'a:b', classes: {'sm:hover', 'w-1/2'}),
          attributes: const {'data-applied': 'true'},
          child: SlottedChildView(slots: const []),
        ),
      );

      final children = window.document.querySelector('section')!.children;
      expect(children.item(0)!.getAttribute('data-applied'), 'true');
      for (var i = 1; i < children.length; i++) {
        expect(children.item(i)!.hasAttribute('data-applied'), isFalse);
      }
    });

    for (final (description, target, expected) in const <(String, ApplyTarget, List<String>)>[
      ('child with an empty ID', .childWith(tag: 'button', id: ''), ['Missing', 'Empty']),
      ('descendant with an empty ID', .descendantWith(tag: 'button', id: ''), ['Missing', 'Empty', 'Nested']),
      ('child with an empty tag', .childWith(tag: ''), []),
      ('descendant with an empty tag', .descendantWith(tag: '', classes: {'selected'}), []),
      ('child with an empty class name', .childWith(classes: {''}), []),
      ('descendant with an empty class name', .descendantWith(classes: {'selected', ''}), []),
      (
        'descendant with an empty class set',
        .descendantWith(tag: 'button', classes: {}),
        [
          'Missing',
          'Empty',
          'Named',
          'Nested',
          'Other',
        ],
      ),
    ]) {
      testClient('matches a $description', (tester) async {
        window.document.body!.innerHTML =
            '<button>Missing</button>'
                    '<button id="">Empty</button>'
                    '<button id="named">Named</button>'
                    '<section class="selected">'
                    '<button class="selected">Nested</button>'
                    '<button id="other">Other</button>'
                    '</section>'
                .toJS;

        tester.pumpComponent(
          .apply(
            target: target,
            attributes: const {'data-applied': 'true'},
            child: SlottedChildView(slots: const []),
          ),
        );

        final matches = window.document.querySelectorAll('[data-applied]');
        expect([for (var i = 0; i < matches.length; i++) matches.item(i)!.textContent], expected);
      });
    }

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

    testClient('removes applied params when toggled off even if initially present in html', (tester) async {
      window.document.body!.innerHTML = '<section><button id="applied-id" class="original applied" style="color: red;" data-applied="true" data-j-apply="i:applied-id;c:applied;s:color;a:data-applied">Static</button></section>'
          .toJS;
      var hasParams = true;
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .apply(
              target: .descendantWith(tag: 'button'),
              id: hasParams ? 'applied-id' : null,
              classes: hasParams ? 'applied' : null,
              styles: hasParams ? const Styles(color: Colors.red) : null,
              attributes: hasParams ? const {'data-applied': 'true'} : null,
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

      setState(() => hasParams = false);
      await pumpEventQueue();

      expect(btn.hasAttribute('id'), isFalse);
      expect(btn.className, 'original');
      expect(btn.hasAttribute('style'), isFalse);
      expect(btn.hasAttribute('data-applied'), isFalse);
    });

    testClient('preserves child-owned id and classes when client apply toggles off', (tester) async {
      window.document.body!.innerHTML =
          '<section><button id="save" class="btn active" data-j-apply="c:active">Save</button></section>'.toJS;
      var hasParams = true;
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .apply(
              target: .descendantWith(tag: 'button'),
              id: hasParams ? 'save' : null,
              classes: hasParams ? 'active' : null,
              child: SlottedChildView(slots: const []),
            );
          },
        ),
      );

      final btn = window.document.querySelector('button')! as HTMLElement;
      expect(btn.id, 'save');
      expect(btn.className, 'btn active');

      setState(() => hasParams = false);
      await pumpEventQueue();

      expect(btn.id, 'save');
      expect(btn.className, 'btn');
    });

    // To be revisited: slotted child hydration with raw inline styles.
    testClient(
      'does not apply wrapper styles during hydration when element has raw inline styles in html',
      (tester) async {
        window.document.body!.innerHTML = '<section><button style="color: blue;">Static</button></section>'.toJS;

        tester.pumpComponent(
          Component.apply(
            target: const ApplyTarget.descendantWith(tag: 'button'),
            styles: const Styles(backgroundColor: Colors.yellow, color: Colors.red),
            child: SlottedChildView(slots: const []),
          ),
        );

        final btn = window.document.querySelector('button')! as HTMLElement;
        expect(btn.style.color, 'blue');
        expect(btn.style.backgroundColor, '');
      },
      skip: true,
    );

    // To be revisited: slotted child hydration with raw class attribute.
    testClient(
      'does not apply wrapper classes during hydration when element has raw class in attributes',
      (tester) async {
        window.document.body!.innerHTML = '<section><button class="label">Static</button></section>'.toJS;

        tester.pumpComponent(
          Component.apply(
            target: const ApplyTarget.descendantWith(tag: 'button'),
            classes: 'highlight',
            child: SlottedChildView(slots: const []),
          ),
        );

        final btn = window.document.querySelector('button')! as HTMLElement;
        expect(btn.className, 'label');
      },
      skip: true,
    );

    // To be revisited: CSS shorthand and longhand property overlap.
    testClient(
      'preserves child shorthand styles when wrapper applies overlapping longhand style',
      (tester) async {
        window.document.body!.innerHTML = '<section><button style="margin: 4px;">Static</button></section>'.toJS;
        var hasParams = true;
        late void Function(void Function() cb) setState;

        tester.pumpComponent(
          StatefulBuilder(
            builder: (context, set) {
              setState = set;
              return Component.apply(
                target: const ApplyTarget.descendantWith(tag: 'button'),
                styles: hasParams ? Styles(margin: Margin.only(left: 8.px)) : null,
                child: SlottedChildView(slots: const []),
              );
            },
          ),
        );

        final btn = window.document.querySelector('button')! as HTMLElement;
        expect(btn.style.marginLeft, '4px');

        setState(() => hasParams = false);
        await pumpEventQueue();

        expect(btn.style.marginLeft, '4px');
      },
      skip: true,
    );

    testClient('re-hydrates data-j-apply on reload and cleans up when apply is disabled', (tester) async {
      const html =
          '<section><button id="applied-id" class="original applied" data-j-apply="i:applied-id;c:applied">Static</button></section>';
      window.document.body!.innerHTML = html.toJS;
      var hasParams = true;
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .apply(
              target: .descendantWith(tag: 'button'),
              id: hasParams ? 'applied-id' : null,
              classes: hasParams ? 'applied' : null,
              child: SlottedChildView(slots: const []),
            );
          },
        ),
      );

      var btn = window.document.querySelector('button')! as HTMLElement;
      expect(btn.id, 'applied-id');
      expect(btn.className, 'original applied');

      // Reload with fresh server DOM containing data-j-apply
      await _reload(tester, html);

      btn = window.document.querySelector('button')! as HTMLElement;
      expect(btn.id, 'applied-id');
      expect(btn.className, 'original applied');

      // Now toggle off the apply params
      setState(() => hasParams = false);
      await pumpEventQueue();

      expect(btn.hasAttribute('id'), isFalse);
      expect(btn.className, 'original');
    });

    testClient('preserves outer applied params when inner apply toggles off', (tester) async {
      window.document.body!.innerHTML = '<section><button class="child-class server-class client-class" data-j-apply="c:server-class,client-class">Button</button></section>'
          .toJS;
      var hasParams = true;
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .apply(
              target: .descendantWith(tag: 'button'),
              classes: 'server-class',
              child: .apply(
                target: .descendantWith(tag: 'button'),
                classes: hasParams ? 'client-class' : null,
                child: SlottedChildView(slots: const []),
              ),
            );
          },
        ),
      );

      final btn = window.document.querySelector('button')! as HTMLElement;
      expect(btn.className, 'child-class client-class server-class');

      setState(() => hasParams = false);
      await pumpEventQueue();

      expect(btn.className, 'child-class server-class');
    });

    testClient('correctly unescapes special characters in data-j-apply', (tester) async {
      window.document.body!.innerHTML = '<section><button id="btn;1,2%3" class="c;1 c,2" data-j-apply="i:btn%3B1%2C2%253;c:c%3B1,c%2C2">Escape</button></section>'
          .toJS;
      var hasParams = true;
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .apply(
              target: .descendantWith(tag: 'button'),
              id: hasParams ? 'btn;1,2%3' : null,
              classes: hasParams ? 'c;1 c,2' : null,
              child: SlottedChildView(slots: const []),
            );
          },
        ),
      );

      final btn = window.document.querySelector('button')! as HTMLElement;
      expect(btn.id, 'btn;1,2%3');
      expect(btn.className, 'c;1 c,2');

      setState(() => hasParams = false);
      await pumpEventQueue();

      expect(btn.hasAttribute('id'), isFalse);
      expect(btn.className, '');
    });

    testClient('preserves server-only applied params when client apply toggles off', (tester) async {
      window.document.body!.innerHTML = '<section><button id="save" class="btn server-applied client-applied" data-j-apply="c:client-applied">Save</button></section>'
          .toJS;
      var hasParams = true;
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .apply(
              target: .descendantWith(tag: 'button'),
              classes: hasParams ? 'client-applied' : null,
              child: SlottedChildView(slots: const []),
            );
          },
        ),
      );

      final btn = window.document.querySelector('button')! as HTMLElement;
      expect(btn.className, 'btn server-applied client-applied');

      setState(() => hasParams = false);
      await pumpEventQueue();

      expect(btn.className, 'btn server-applied');
    });

    testClient('hydrates and cleans up data-j-apply on SVG root element', (tester) async {
      window.document.body!.innerHTML =
          '<svg class="icon applied" data-j-apply="c:applied" width="100" height="100"></svg>'.toJS;
      var hasParams = true;
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .apply(
              target: .childWith(tag: 'svg'),
              classes: hasParams ? 'applied' : null,
              child: SlottedChildView(slots: const []),
            );
          },
        ),
      );

      final svg = window.document.querySelector('svg')!;
      expect(svg.getAttribute('class'), 'icon applied');

      setState(() => hasParams = false);
      await pumpEventQueue();

      expect(svg.getAttribute('class'), 'icon');
    });

    testClient('hydrates and cleans up data-j-apply on range slot element anchors', (tester) async {
      window.document.body!.innerHTML =
          '<span class="anchor applied" data-j-apply="c:applied">Start</span>'
                  '<button>Slot Content</button>'
                  '<span class="end-anchor applied" data-j-apply="c:applied">End</span>'
              .toJS;
      final spans = window.document.querySelectorAll('span');
      final start = spans.item(0)! as HTMLElement;
      final end = spans.item(1)! as HTMLElement;
      var hasParams = true;
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .apply(
              target: .descendantWith(tag: 'span'),
              classes: hasParams ? 'applied' : null,
              child: SlottedChildView(
                slots: [
                  ChildSlot.between(start: start, end: end, child: button([])),
                ],
              ),
            );
          },
        ),
      );

      expect(start.getAttribute('class'), 'anchor applied');
      expect(end.getAttribute('class'), 'end-anchor applied');

      setState(() => hasParams = false);
      await pumpEventQueue();

      expect(start.getAttribute('class'), 'anchor');
      expect(end.getAttribute('class'), 'end-anchor');
    });

    testClient('leaves data-j-apply in nested range slot for inner view to hydrate', (tester) async {
      window.document.body!.innerHTML = '<section><main><!--start--><button id="inner" class="btn" data-j-apply="i:inner">Inner</button><!--end--></main></section>'
          .toJS;
      final mainElement = window.document.querySelector('main')!;
      var hasInnerApply = true;
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return Component.apply(
              target: const ApplyTarget.descendantWith(tag: 'button'),
              classes: 'outer-class',
              child: SlottedChildView(
                slots: [
                  ChildSlot.between(
                    start: mainElement.firstChild!,
                    end: mainElement.lastChild!,
                    child: Component.apply(
                      target: const ApplyTarget.childWith(tag: 'button'),
                      id: hasInnerApply ? 'inner' : null,
                      child: SlottedChildView(slots: const []),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final btn = window.document.querySelector('button')! as HTMLElement;
      expect(btn.id, 'inner');
      expect(btn.classList.contains('outer-class'), isTrue);

      setState(() => hasInnerApply = false);
      await pumpEventQueue();

      expect(btn.hasAttribute('id'), isFalse);
    });

    testClient('leaves data-j-apply in nested query slot for inner view to hydrate', (tester) async {
      window.document.body!.innerHTML = '<section><main class="slot-target"><button id="inner" class="btn" data-j-apply="i:inner">Inner</button></main></section>'
          .toJS;
      var hasInnerApply = true;
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return Component.apply(
              target: const ApplyTarget.descendantWith(tag: 'button'),
              classes: 'outer-class',
              child: SlottedChildView(
                slots: [
                  ChildSlot.fromQuery(
                    '.slot-target',
                    child: Component.apply(
                      target: const ApplyTarget.childWith(tag: 'button'),
                      id: hasInnerApply ? 'inner' : null,
                      child: SlottedChildView(slots: const []),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final btn = window.document.querySelector('button')! as HTMLElement;
      expect(btn.id, 'inner');
      expect(btn.classList.contains('outer-class'), isTrue);

      setState(() => hasInnerApply = false);
      await pumpEventQueue();

      expect(btn.hasAttribute('id'), isFalse);
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
    }

    testClient('hands applied params to the child hydrating a range added after the first render', (tester) async {
      window.document.body!.innerHTML = '<section><!--start--><button></button><!--end--></section>'.toJS;
      final section = window.document.querySelector('section')!;
      final start = section.childNodes.item(0)!;
      final end = section.childNodes.item(2)!;
      final btn = section.querySelector('button')!;
      var showSlot = false;
      var enabled = true;
      late void Function(void Function()) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .apply(
              target: const .descendantWith(tag: 'button'),
              attributes: enabled ? const {'data-owner': 'outer', 'data-outer': 'true'} : null,
              child: SlottedChildView(
                slots: [
                  if (showSlot)
                    .between(
                      start: start,
                      end: end,
                      child: button(attributes: const {'data-owner': 'child'}, []),
                    ),
                ],
              ),
            );
          },
        ),
      );

      expect(btn.getAttribute('data-owner'), 'outer');
      setState(() => showSlot = true);
      await pumpEventQueue();
      expect(window.document.querySelector('button'), equals(btn));
      expect(btn.getAttribute('data-owner'), 'child');
      expect(btn.getAttribute('data-outer'), 'true');

      // The child applies the remaining values itself now, so they go when the apply does.
      setState(() => enabled = false);
      await pumpEventQueue();
      expect(btn.getAttribute('data-owner'), 'child');
      expect(btn.hasAttribute('data-outer'), isFalse);
    });

    testClient('hands applied params to the child hydrating a new query slot', (tester) async {
      window.document.body!.innerHTML =
          '<section><main><div><button></button></div></main><button></button></section>'.toJS;
      final slotted = window.document.querySelector('main button')! as HTMLElement;
      final outside = window.document.querySelector('main + button')! as HTMLElement;
      var showSlot = false;
      var enabled = true;
      var ownClicks = 0;
      var appliedClicks = 0;
      late void Function(void Function()) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .apply(
              target: const .descendantWith(tag: 'button'),
              classes: enabled ? 'shared' : null,
              styles: enabled ? const Styles(color: Colors.red) : null,
              attributes: enabled ? const {'data-target': 'true'} : null,
              events: enabled ? {'click': (_) => appliedClicks++} : null,
              child: SlottedChildView(
                slots: [
                  if (showSlot)
                    .fromQuery(
                      'main:has(button[data-target="true"])',
                      child: div([
                        button(
                          classes: 'shared',
                          styles: const Styles(color: Colors.blue),
                          attributes: const {'data-target': 'own'},
                          events: {'click': (_) => ownClicks++},
                          [],
                        ),
                      ]),
                    ),
                ],
              ),
            );
          },
        ),
      );

      // The selector already matches when the child takes over the button.
      expect(slotted.getAttribute('data-target'), 'true');
      setState(() => showSlot = true);
      await pumpEventQueue();

      expect(window.document.querySelector('main button'), equals(slotted));
      expect(slotted.getAttribute('data-target'), 'own');
      expect(slotted.style.color, 'blue');
      expect(outside.getAttribute('data-target'), 'true');
      slotted.click();
      expect(ownClicks, 1);
      expect(appliedClicks, 0);
      outside.click();
      expect(appliedClicks, 1);

      setState(() => enabled = false);
      await pumpEventQueue();
      expect(slotted.className, 'shared');
      expect(slotted.getAttribute('data-target'), 'own');
      expect(slotted.style.color, 'blue');
      expect(outside.hasAttribute('data-target'), isFalse);

      // Once the slot is removed, the view can bind the remaining button again.
      setState(() {
        showSlot = false;
        enabled = true;
      });
      await pumpEventQueue();
      expect(window.document.querySelector('main button'), equals(slotted));
      expect(slotted.getAttribute('data-target'), 'own');
      slotted.click();
      expect(ownClicks, 1);
      expect(appliedClicks, 2);
    });

    testClient('releases inherited values before a new view takes over the same nodes', (tester) async {
      final section = window.document.createElement('section')..innerHTML = '<main><button></button></main>'.toJS;
      final nodes = [section];
      final btn = section.querySelector('button')!;
      var replaced = false;
      late void Function(void Function()) setView;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setView = set;
            return .apply(
              target: const .descendantWith(tag: 'button'),
              attributes: replaced ? const {'data-version': 'new'} : const {'data-version': 'old', 'data-retired': ''},
              child: SlottedChildView.withNodes(
                key: ValueKey(replaced),
                nodes: nodes,
                slots: [
                  if (!replaced) .fromQuery('main', child: button(classes: 'own', [])),
                ],
              ),
            );
          },
        ),
      );

      expect(btn.getAttribute('data-version'), 'old');
      expect(btn.hasAttribute('data-retired'), isTrue);
      setView(() => replaced = true);
      await pumpEventQueue();
      expect(window.document.querySelector('button'), equals(btn));
      expect(btn.hasAttribute('data-retired'), isFalse);
      expect(btn.getAttribute('data-version'), 'new');
      expect(btn.className, 'own');
      tester.binding.detachRootComponent();
      expect(btn.hasAttribute('data-version'), isFalse);
    });

    testClient('applies direct child params after a keyed range moves into a view rooted at its parent', (
      tester,
    ) async {
      window.document.body!.innerHTML = '<section><main><!--start--><button></button><!--end--></main></section>'.toJS;
      final main = window.document.querySelector('main')!;
      final start = main.childNodes.item(0)!;
      final end = main.childNodes.item(2)!;
      final btn = main.querySelector('button')!;
      final slotKey = GlobalKey();
      var moved = false;
      late void Function(void Function()) setState;

      ChildSlot range() => .between(key: slotKey, start: start, end: end, child: button([]));

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return SlottedChildView(
              slots: [
                if (!moved)
                  range()
                else
                  .fromQuery(
                    'main',
                    child: .apply(
                      target: const .childWith(tag: 'button'),
                      classes: 'direct',
                      child: SlottedChildView(slots: [range()]),
                    ),
                  ),
              ],
            );
          },
        ),
      );

      expect(btn.className, '');
      setState(() => moved = true);
      await pumpEventQueue();
      expect(window.document.querySelector('main button'), equals(btn));
      // The button is now a DOM child of the element the apply renders into.
      expect(btn.className, 'direct');
    });

    testClient('hands applied params to a keyed slot moved into a new view', (tester) async {
      final section = window.document.createElement('section')..innerHTML = '<main><button></button></main>'.toJS;
      final nodes = [section];
      final btn = section.querySelector('button')!;
      final slotKey = GlobalKey();
      var moved = false;
      late void Function(void Function()) setState;

      Component view() => .apply(
        target: const .descendantWith(tag: 'button'),
        attributes: moved ? const {'data-target': 'true'} : null,
        child: SlottedChildView.withNodes(
          nodes: nodes,
          slots: [
            .fromQuery(
              'main',
              key: slotKey,
              child: button(attributes: moved ? const {'data-target': 'own'} : null, []),
            ),
          ],
        ),
      );

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .fragment([
              div(id: 'source', [if (!moved) view()]),
              div(id: 'destination', [if (moved) view()]),
            ]);
          },
        ),
      );

      expect(window.document.querySelector('#source button'), equals(btn));
      setState(() => moved = true);
      await pumpEventQueue();
      expect(window.document.querySelector('#destination button'), equals(btn));
      expect(btn.getAttribute('data-target'), 'own');
    });

    testClient('keeps the values of an apply within a removed slot', (tester) async {
      window.document.body!.innerHTML = '<section><main><button></button></main></section>'.toJS;
      final btn = window.document.querySelector('button')! as HTMLElement;
      var showSlot = true;
      var enabled = true;
      late void Function(void Function()) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .apply(
              target: const .descendantWith(tag: 'button'),
              attributes: enabled ? const {'data-outer': 'true'} : null,
              child: SlottedChildView(
                slots: [
                  if (showSlot)
                    .fromQuery(
                      'main',
                      child: .apply(
                        classes: 'inner',
                        attributes: const {'data-inner': 'true'},
                        child: button(classes: 'own', []),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );

      expect(btn.className, 'own inner');
      expect(btn.getAttribute('data-outer'), 'true');

      setState(() => showSlot = false);
      await pumpEventQueue();
      expect(window.document.querySelector('button'), equals(btn));
      expect(btn.className, 'own inner');
      expect(btn.getAttribute('data-inner'), 'true');
      expect(btn.getAttribute('data-outer'), 'true');

      // The view took back only the values of the apply above it.
      setState(() => enabled = false);
      await pumpEventQueue();
      expect(btn.className, 'own inner');
      expect(btn.getAttribute('data-inner'), 'true');
      expect(btn.hasAttribute('data-outer'), isFalse);
    });

    testClient('takes back its params through a nested view in a removed slot', (tester) async {
      window.document.body!.innerHTML =
          '<section><main><article><div><button></button></div></article></main></section>'.toJS;
      final btn = window.document.querySelector('button')! as HTMLElement;
      var showSlot = true;
      var enabled = true;
      var clicks = 0;
      late void Function(void Function()) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .apply(
              target: const .descendantWith(tag: 'button'),
              attributes: enabled ? const {'data-outer': 'true'} : null,
              events: enabled ? {'click': (_) => clicks++} : null,
              child: SlottedChildView(
                slots: [
                  if (showSlot)
                    .fromQuery(
                      'main',
                      child: .apply(
                        target: const .descendantWith(tag: 'button'),
                        classes: 'middle',
                        child: SlottedChildView(
                          slots: [
                            .fromQuery('div', child: button(classes: 'own', [])),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );

      btn.click();
      expect(clicks, 1);
      expect(btn.className, 'own middle');
      expect(btn.getAttribute('data-outer'), 'true');

      setState(() => showSlot = false);
      await pumpEventQueue();
      btn.click();
      expect(clicks, 2);
      expect(btn.className, 'own middle');
      expect(btn.getAttribute('data-outer'), 'true');

      setState(() => enabled = false);
      await pumpEventQueue();
      btn.click();
      expect(clicks, 2);
      expect(btn.className, 'own middle');
      expect(btn.hasAttribute('data-outer'), isFalse);
    });

    testClient('keeps the values of an apply within a removed slot on static nodes of a nested view', (tester) async {
      window.document.body!.innerHTML = '<section><main><article><p></p></article></main></section>'.toJS;
      final p = window.document.querySelector('p')! as HTMLElement;
      var showSlot = true;
      var enabled = true;
      var outerClicks = 0;
      var middleHovers = 0;
      late void Function(void Function()) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .apply(
              target: const .descendantWith(tag: 'p'),
              attributes: enabled ? const {'data-outer': 'true'} : null,
              events: enabled ? {'click': (_) => outerClicks++} : null,
              child: SlottedChildView(
                slots: [
                  if (showSlot)
                    .fromQuery(
                      'main',
                      child: .apply(
                        target: const .descendantWith(tag: 'p'),
                        classes: 'middle',
                        events: {'mouseover': (_) => middleHovers++},
                        child: SlottedChildView(slots: const []),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );

      void hover() => p.dispatchEvent(Event('mouseover'));

      p.click();
      hover();
      expect(outerClicks, 1);
      expect(middleHovers, 1);
      expect(p.className, 'middle');
      expect(p.getAttribute('data-outer'), 'true');

      setState(() => showSlot = false);
      await pumpEventQueue();
      expect(window.document.querySelector('p'), equals(p));
      expect(p.className, 'middle');
      expect(p.getAttribute('data-outer'), 'true');
      // The outer view binds its listener once, and the removed apply's listener is gone.
      p.click();
      hover();
      expect(outerClicks, 2);
      expect(middleHovers, 1);

      // The outer view took back only the values of the apply above it.
      setState(() => enabled = false);
      await pumpEventQueue();
      p.click();
      expect(outerClicks, 2);
      expect(p.className, 'middle');
      expect(p.hasAttribute('data-outer'), isFalse);
    });

    testClient('removes the valid values of a malformed data-j-apply marker', (tester) async {
      // An empty or space-separated class name isn't a valid token to remove.
      window.document.body!.innerHTML =
          '<section><p class="a b own" data-x="1" data-j-apply="c:a,,x y,b;a:data-x"></p></section>'.toJS;
      final p = window.document.querySelector('p')! as HTMLElement;

      tester.pumpComponent(
        .apply(
          target: const .descendantWith(tag: 'p'),
          attributes: const {'data-applied': 'true'},
          child: SlottedChildView(slots: const []),
        ),
      );

      expect(p.hasAttribute('data-j-apply'), isFalse);
      expect(p.className, 'own');
      expect(p.hasAttribute('data-x'), isFalse);
      expect(p.getAttribute('data-applied'), 'true');
    });

    testClient('resolves a query slot using values applied within a later range slot', (tester) async {
      window.document.body!.innerHTML = '<section><main></main><!--start--><button></button><!--end--></section>'.toJS;
      final section = window.document.querySelector('section')!;
      final start = section.childNodes.item(1)!;
      final end = section.childNodes.item(3)!;
      final btn = window.document.querySelector('button')! as HTMLElement;

      tester.pumpComponent(
        .apply(
          target: const .descendantWith(tag: 'button'),
          attributes: const {'data-target': 'true'},
          child: SlottedChildView(
            slots: [
              .fromQuery('section:has(button[data-target="true"]) > main', child: span([])),
              .between(start: start, end: end, child: button([])),
            ],
          ),
        ),
      );

      expect(window.document.querySelector('main > span'), isNotNull);
      expect(window.document.querySelector('button'), equals(btn));
      expect(btn.getAttribute('data-target'), 'true');
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

    testClient('keeps a dialog and details the browser opened open in a removed slot', (tester) async {
      window.document.body!.innerHTML =
          '<button></button><!--start--><dialog>Content</dialog><details><summary>More</summary></details><!--end-->'
              .toJS;
      final outside = window.document.querySelector('button')! as HTMLElement;
      final dialogElement = window.document.querySelector('dialog')! as HTMLDialogElement;
      final detailsElement = window.document.querySelector('details')! as HTMLDetailsElement;
      final start = dialogElement.previousSibling!;
      final end = detailsElement.nextSibling!;
      var slotted = true;
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            // The applied `open` goes away along with the slot.
            final attributes = slotted ? const {'open': 'false'} : null;
            return .apply(
              target: const .descendantWith(tag: 'dialog'),
              attributes: attributes,
              child: .apply(
                target: const .descendantWith(tag: 'details'),
                attributes: attributes,
                child: SlottedChildView(
                  slots: [
                    if (slotted)
                      .between(
                        start: start,
                        end: end,
                        child: .fragment([
                          dialog([.text('Content')]),
                          details([
                            summary([.text('More')]),
                          ]),
                        ]),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      expect(dialogElement.open, isFalse);
      expect(detailsElement.open, isFalse);
      dialogElement.showModal();
      detailsElement.open = true;

      setState(() => slotted = false);
      await pumpEventQueue();

      // Removing `open` would hide the modal dialog without closing it, leaving the page inert.
      expect(window.document.querySelector('dialog'), equals(dialogElement));
      expect(dialogElement.open, isTrue);
      expect(dialogElement.matches(':modal'), isTrue);
      expect(detailsElement.open, isTrue);

      dialogElement.close();
      outside.focus();
      expect(window.document.activeElement, equals(outside));
    });

    for (final nested in [false, true]) {
      final removal = nested ? 'the slot around its view is removed' : 'its applied open is removed';
      testClient('keeps a static dialog reopened with showModal() open when $removal', (tester) async {
        window.document.body!.innerHTML =
            '<button></button><section><main><article><dialog>Content</dialog></article></main></section>'.toJS;
        final outside = window.document.querySelector('button')! as HTMLElement;
        final dialogElement = window.document.querySelector('dialog')! as HTMLDialogElement;
        var applied = true;
        late void Function(void Function() cb) setState;

        tester.pumpComponent(
          StatefulBuilder(
            builder: (context, set) {
              setState = set;
              return .apply(
                target: const .descendantWith(tag: 'dialog'),
                attributes: applied ? const {'open': ''} : null,
                child: SlottedChildView(
                  slots: [
                    // The slot goes away along with the applied `open`.
                    if (nested && applied) .fromQuery('main', child: article([SlottedChildView(slots: const [])])),
                  ],
                ),
              );
            },
          ),
        );

        // The view added `open`, so the dialog isn't modal. Reopening it as one replaces that attribute.
        expect(dialogElement.open, isTrue);
        expect(dialogElement.matches(':modal'), isFalse);
        dialogElement.close();
        dialogElement.showModal();

        setState(() => applied = false);
        await pumpEventQueue();

        // Removing `open` would hide the modal dialog without closing it, leaving the page inert.
        expect(window.document.querySelector('dialog'), equals(dialogElement));
        expect(dialogElement.open, isTrue);
        expect(dialogElement.matches(':modal'), isTrue);

        dialogElement.close();
        outside.focus();
        expect(window.document.activeElement, equals(outside));
      });
    }

    testClient('removes an applied open from static details and a static dialog that is not modal', (tester) async {
      window.document.body!.innerHTML = '<dialog>Content</dialog><details><summary>More</summary></details>'.toJS;
      final dialogElement = window.document.querySelector('dialog')! as HTMLDialogElement;
      final detailsElement = window.document.querySelector('details')! as HTMLDetailsElement;
      var applied = true;
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            final attributes = applied ? const {'open': ''} : null;
            return .apply(
              target: const .descendantWith(tag: 'dialog'),
              attributes: attributes,
              child: .apply(
                target: const .descendantWith(tag: 'details'),
                attributes: attributes,
                child: SlottedChildView(slots: const []),
              ),
            );
          },
        ),
      );

      expect(dialogElement.open, isTrue);
      expect(detailsElement.open, isTrue);

      // The view opened both by adding `open`, so it closes them again by removing it.
      setState(() => applied = false);
      await pumpEventQueue();
      expect(dialogElement.hasAttribute('open'), isFalse);
      expect(detailsElement.hasAttribute('open'), isFalse);
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

    testClient('applies direct child params to the element anchors of adjacent range slots', (tester) async {
      window.document.body!.innerHTML =
          '<span></span><button></button><span></span><button></button><span></span>'.toJS;
      final anchors = window.document.querySelectorAll('span');
      final shared = anchors.item(1)!;
      var clicks = 0;

      tester.pumpComponent(
        .apply(
          target: ApplyTarget.anyChild,
          classes: 'anchor',
          events: {'click': (_) => clicks++},
          child: SlottedChildView(
            slots: [
              .between(start: anchors.item(0)!, end: shared, child: button([])),
              .between(start: shared, end: anchors.item(2)!, child: button([])),
            ],
          ),
        ),
      );

      expect(window.document.querySelectorAll('span.anchor').length, 3);

      // The view skips the slots' contents, so only
      // the slots' own components bind the buttons' listeners.
      final buttons = window.document.querySelectorAll('button');
      (buttons.item(0)! as HTMLElement).click();
      (buttons.item(1)! as HTMLElement).click();
      expect(clicks, 2);

      tester.binding.detachRootComponent();
      expect(window.document.querySelectorAll('span.anchor').length, 0);
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

    testClient('checks range membership without scanning its contents for each static sibling', (tester) async {
      const count = 32;
      final body = window.document.body!;
      final inside = '<em></em>' * count;
      final outside = '<i></i>' * count;
      body.innerHTML = '<!--start-->$inside<!--end-->$outside'.toJS;
      final start = body.firstChild!;
      final end = body.childNodes.item(count + 1)!;
      var containsCalls = 0;
      final contents = body.querySelectorAll('em');
      for (var i = 0; i < contents.length; i++) {
        final node = contents.item(i)!;
        // Each range node is a leaf. Count containment checks on these nodes
        // without changing the shared DOM prototype or depending on elapsed time.
        node['contains'] = ((Node? other) {
          containsCalls++;
          return node == other;
        }).toJS;
      }

      tester.pumpComponent(
        .apply(
          target: const .descendantWith(tag: 'i'),
          classes: 'static',
          child: SlottedChildView(
            slots: [
              .between(start: start, end: end, child: span([])),
            ],
          ),
        ),
      );

      expect(body.querySelectorAll('i.static').length, count);
      expect(body.querySelectorAll('span').length, 1);
      expect(containsCalls, lessThanOrEqualTo(count));
    });

    testClient('checks static matches without rescanning them as each range slot mounts', (tester) async {
      const count = 32;
      final body = window.document.body!;
      body.innerHTML = '<section>${'<i></i>' * count}${'<!--start--><b></b><!--end-->' * count}</section>'.toJS;
      final section = body.firstChild!;
      final children = [for (var i = 0; i < section.childNodes.length; i++) section.childNodes.item(i)!];
      final matches = children.take(count);
      final anchors = children.skip(count).toList();
      var parentReads = 0;
      final object = globalContext['Object']! as JSObject;
      for (final node in matches) {
        // Count ancestor lookups on these nodes without
        // changing the shared DOM prototype or depending on elapsed time.
        // They don't move, so return their original parent.
        final descriptor = JSObject()
          ..['configurable'] = true.toJS
          ..['get'] = (() {
            parentReads++;
            return section;
          }).toJS;
        object.callMethod('defineProperty'.toJS, node, 'parentNode'.toJS, descriptor);
      }

      tester.pumpComponent(
        .apply(
          target: const .descendantWith(tag: 'i'),
          classes: 'static',
          child: SlottedChildView(
            slots: [
              for (var i = 0; i < count; i++) .between(start: anchors[i * 3], end: anchors[i * 3 + 2], child: b([])),
            ],
          ),
        ),
      );

      expect(body.querySelectorAll('i.static').length, count);
      expect(body.querySelectorAll('b.static').length, 0);
      // The view checks each match once per render, and it renders twice as it mounts below an apply,
      // but mounting each range slot doesn't check them again.
      expect(parentReads, lessThanOrEqualTo(2 * count));
    });

    testClient('takes back removed range slots without listing the others again as each one unmounts', (tester) async {
      const count = 32;
      final body = window.document.body!;
      body.innerHTML = '<section>${'<!--start--><b></b><!--end-->' * count}</section>'.toJS;
      final section = body.firstChild!;
      final anchors = [for (var i = 0; i < section.childNodes.length; i++) section.childNodes.item(i)!];
      var slotted = true;
      var enabled = true;
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .apply(
              target: const .descendantWith(tag: 'b'),
              classes: enabled ? 'applied' : null,
              child: SlottedChildView(
                slots: [
                  if (slotted)
                    for (var i = 0; i < count; i++)
                      .between(start: anchors[i * 3], end: anchors[i * 3 + 2], child: b([])),
                ],
              ),
            );
          },
        ),
      );

      var siblingReads = 0;
      final object = globalContext['Object']! as JSObject;
      for (var i = 0; i < count; i++) {
        // Listing the contents of a range reads the next sibling of each node in it.
        // Count those reads without changing the shared DOM prototype or depending on elapsed time.
        // The nodes don't move, so return their original sibling.
        final end = anchors[i * 3 + 2];
        final descriptor = JSObject()
          ..['configurable'] = true.toJS
          ..['get'] = (() {
            siblingReads++;
            return end;
          }).toJS;
        object.callMethod('defineProperty'.toJS, anchors[i * 3 + 1], 'nextSibling'.toJS, descriptor);
      }

      setState(() => slotted = false);
      await pumpEventQueue();

      expect(body.querySelectorAll('b.applied').length, count);
      // The view lists each removed range once as it renders and once as it takes them all back.
      expect(siblingReads, lessThanOrEqualTo(2 * count));

      // The view now owns the values on each node it took back.
      setState(() => enabled = false);
      await pumpEventQueue();
      expect(body.querySelectorAll('b.applied').length, 0);
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
