@TestOn('vm')
library;

import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr/src/framework/framework.dart';
import 'package:jaspr_test/server_test.dart';

import '../utils/test_component.dart';

void main() {
  group('Component.apply', () {
    setUpAll(() {
      Jaspr.initializeApp();
    });

    test('renders single applied element', () async {
      final result = await renderComponent(
        Component.apply(
          id: 'test',
          classes: 'example',
          styles: Styles(color: Colors.red),
          attributes: {'aria-label': 'test'},
          child: div([]),
        ),
        standalone: true,
      );

      expect(
        result.body,
        decodedMatches('<div id="test" class="example" style="color: red" aria-label="test"></div>\n'),
      );
    });

    test('normalizes whitespace between applied class names', () async {
      final result = await renderComponent(
        Component.apply(
          classes: '  first\tsecond\n ',
          child: div([]),
        ),
        standalone: true,
      );

      expect(
        result.body,
        decodedMatches('<div class="first second"></div>\n'),
      );
    });

    test('merges component props with inherited props', () async {
      final result = await renderComponent(
        Component.apply(
          id: 'test',
          classes: 'example',
          styles: Styles(color: Colors.red, backgroundColor: Colors.blue),
          attributes: {'aria-label': 'test'},
          child: div(
            id: 'main',
            classes: 'container',
            styles: Styles(display: Display.flex, color: Colors.green),
            attributes: {'data-test': 'example'},
            [],
          ),
        ),
        standalone: true,
      );

      expect(
        result.body,
        decodedMatches(
          '<div id="main" class="container example" style="display: flex; color: green; background-color: blue" data-test="example" aria-label="test"></div>\n',
        ),
      );
    });

    test('outer apply can target inner apply', () async {
      final result = await renderComponent(
        Component.apply(
          target: ApplyTarget.childWith(id: 'id-1'),
          classes: 'outer',
          child: Component.apply(
            id: 'id-1',
            classes: 'inner',
            child: div([]),
          ),
        ),
        standalone: true,
      );

      expect(
        result.body,
        decodedMatches(
          '<div id="id-1" class="inner outer"></div>\n',
        ),
      );
    });

    test('can target only direct child', () async {
      final result = await renderComponent(
        Component.apply(
          id: 'test',
          classes: 'example',
          child: div([
            p([Component.text('Hello World')]),
          ]),
        ),
        standalone: true,
      );

      expect(
        result.body,
        decodedMatches(
          '<div id="test" class="example"><p>Hello World</p></div>\n',
        ),
      );
    });

    test('can target all descendants', () async {
      final result = await renderComponent(
        Component.apply(
          target: ApplyTarget.descendantWith(),
          classes: 'example',
          child: div([
            p([Component.text('Hello World')]),
          ]),
        ),
        standalone: true,
      );

      expect(
        result.body,
        decodedMatches(
          '<div class="example"><p class="example">Hello World</p></div>\n',
        ),
      );
    });

    test('merges properties of multiple applies', () async {
      final result = await renderComponent(
        Component.apply(
          id: 'id-1',
          classes: 'example',
          attributes: {'data-test': 'test-1'},
          child: Component.apply(
            id: 'id-2',
            classes: 'container',
            attributes: {'aria-label': 'test-2'},
            child: div([
              p([]),
            ]),
          ),
        ),
        standalone: true,
      );

      expect(
        result.body,
        decodedMatches(
          '<div id="id-2" class="container example" aria-label="test-2" data-test="test-1"><p></p></div>\n',
        ),
      );
    });

    test('can target descendants by tag', () async {
      final result = await renderComponent(
        Component.apply(
          target: ApplyTarget.descendantWith(tag: 'p'),
          classes: 'example',
          child: div([
            p([]),
            div([
              p([]),
            ]),
          ]),
        ),
        standalone: true,
      );

      expect(
        result.body,
        decodedMatches(
          '<div><p class="example"></p><div><p class="example"></p></div></div>\n',
        ),
      );
    });

    test('can target descendants by id', () async {
      final result = await renderComponent(
        Component.apply(
          target: ApplyTarget.descendantWith(id: 'id-1'),
          classes: 'example',
          child: div([
            div(id: 'id-1', []),
            div(id: 'id-2', []),
          ]),
        ),
        standalone: true,
      );

      expect(
        result.body,
        decodedMatches(
          '<div><div id="id-1" class="example"></div><div id="id-2"></div></div>\n',
        ),
      );
    });

    test('can target descendants by class', () async {
      final result = await renderComponent(
        Component.apply(
          target: ApplyTarget.descendantWith(classes: {'example'}),
          attributes: {'data-test': 'test'},
          child: div([
            div(classes: 'example', []),
            div(classes: 'example other', []),
            div(classes: 'other', []),
          ]),
        ),
        standalone: true,
      );

      expect(
        result.body,
        decodedMatches(
          '<div>\n'
          '  <div class="example" data-test="test"></div>\n'
          '  <div class="example other" data-test="test"></div>\n'
          '  <div class="other"></div>\n'
          '</div>\n',
        ),
      );

      final result2 = await renderComponent(
        Component.apply(
          target: ApplyTarget.descendantWith(classes: {'example', 'other'}),
          attributes: {'data-test': 'test'},
          child: div([
            div(classes: 'example', []),
            div(classes: 'example other', []),
            div(classes: 'example other variant', []),
            div(classes: 'other', []),
          ]),
        ),
        standalone: true,
      );

      expect(
        result2.body,
        decodedMatches(
          '<div>\n'
          '  <div class="example"></div>\n'
          '  <div class="example other" data-test="test"></div>\n'
          '  <div class="example other variant" data-test="test"></div>\n'
          '  <div class="other"></div>\n'
          '</div>\n',
        ),
      );
    });

    test('can target descendants by complex selector', () async {
      final result = await renderComponent(
        Component.apply(
          target: ApplyTarget.descendantWith(tag: 'p', id: 'id-1', classes: {'example'}),
          attributes: {'data-test': 'test'},
          child: div([
            p([]),
            p(id: 'id-1', []),
            p(classes: 'example', []),
            p(id: 'id-1', classes: 'example', []),
            p(id: 'id-1', classes: 'example other', []),
          ]),
        ),
        standalone: true,
      );

      expect(
        result.body,
        decodedMatches(
          '<div>\n'
          '  <p></p>\n'
          '  <p id="id-1"></p>\n'
          '  <p class="example"></p>\n'
          '  <p id="id-1" class="example" data-test="test"></p>\n'
          '  <p id="id-1" class="example other" data-test="test"></p>\n'
          '</div>\n',
        ),
      );
    });

    test('can target descendants with multiple applies', () async {
      final result = await renderComponent(
        Component.apply(
          target: ApplyTarget.descendantWith(classes: {'example'}),
          attributes: {'data-test-1': 'test'},
          child: Component.apply(
            target: ApplyTarget.childWith(tag: 'div'),
            attributes: {'data-test-2': 'test'},
            child: div(classes: 'example', [
              div([]),
              div(classes: 'example', []),
            ]),
          ),
        ),
        standalone: true,
      );

      expect(
        result.body,
        decodedMatches(
          '<div class="example" data-test-2="test" data-test-1="test"><div></div><div class="example" data-test-1="test"></div></div>\n',
        ),
      );
    });

    testComponents('renders single applied element', (tester) async {
      String data = 'test';
      late void Function() callSetState;

      final child = div([]);

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, setState) {
            callSetState = () => setState(() {});
            return Component.apply(
              classes: 'example',
              attributes: {'data': data},
              child: child,
            );
          },
        ),
      );

      expect(find.tag('div'), findsOneComponent);
      final renderObject = (find.tag('div').evaluate().first as RenderObjectElement).renderObject;
      expect(renderObject, isA<TestRenderElement>().having((e) => e.attributes, 'attributes', {'data': 'test'}));

      data = 'test-2';
      callSetState();
      await tester.pump();

      expect(renderObject, isA<TestRenderElement>().having((e) => e.attributes, 'attributes', {'data': 'test-2'}));
    });

    testComponents('preserves child state across reordering when wrapped with wrapWithInheritedDomComponent', (tester) async {
      final keyA = UniqueKey();
      final keyB = UniqueKey();

      final component = FakeComponent(
        child: _TestSlottedParent(
          children: [
            _TestStatefulChild(key: keyA, label: 'A'),
            _TestStatefulChild(key: keyB, label: 'B'),
          ],
        ),
      );

      tester.pumpComponent(component);

      final stateA1 = (find.byKey(keyA).evaluate().first as StatefulElement).state;
      final stateB1 = (find.byKey(keyB).evaluate().first as StatefulElement).state;

      component.updateChild(
        _TestSlottedParent(
          children: [
            _TestStatefulChild(key: keyB, label: 'B'),
            _TestStatefulChild(key: keyA, label: 'A'),
          ],
        ),
      );
      await tester.pump();

      final stateA2 = (find.byKey(keyA).evaluate().first as StatefulElement).state;
      final stateB2 = (find.byKey(keyB).evaluate().first as StatefulElement).state;

      expect(identical(stateA1, stateA2), isTrue);
      expect(identical(stateB1, stateB2), isTrue);
    });

    testComponents('applies inherited dom params to reparented dom element', (tester) async {
      final key = GlobalKey();

      final component = FakeComponent(
        child: div([
          Component.apply(
            classes: 'applied-class',
            child: div([]),
          ),
          span([
            p(key: key, []),
          ]),
        ]),
      );

      tester.pumpComponent(component);

      final pFinder = find.tag('p');
      expect(pFinder, findsOneComponent);
      final renderObject = (pFinder.evaluate().first as RenderObjectElement).renderObject as TestRenderElement;
      expect(renderObject.classes, isNull);

      // Reparent the p element directly under Component.apply
      component.updateChild(
        div([
          Component.apply(
            classes: 'applied-class',
            child: p(key: key, []),
          ),
          span([]),
        ]),
      );
      await tester.pump();

      expect(renderObject.classes, equals('applied-class'));
    });
  });
}

class _TestSlottedParent extends Component {
  const _TestSlottedParent({required this.children});
  final List<Component> children;

  @override
  Element createElement() => _TestSlottedParentElement(this);
}

class _TestSlottedParentElement extends DomRenderObjectElement {
  _TestSlottedParentElement(super.component);

  @override
  _TestSlottedParent get component => super.component as _TestSlottedParent;

  @override
  List<Component> buildOwnChildren() => component.children;

  @override
  List<Component> buildChildren() {
    return [
      for (final child in buildOwnChildren())
        wrapWithInheritedDomComponent(
          getParams: (_) => const [],
          child: child,
        ),
    ];
  }

  @override
  RenderObject createRenderObject() => parentRenderObjectElement!.renderObject.createChildRenderElement('div');

  @override
  void updateRenderObject(RenderElement renderObject) {}
}

class _TestStatefulChild extends StatefulComponent {
  const _TestStatefulChild({super.key, required this.label});
  final String label;

  @override
  State<StatefulComponent> createState() => _TestStatefulChildState();
}

class _TestStatefulChildState extends State<_TestStatefulChild> {
  @override
  Component build(BuildContext context) {
    return Component.text(component.label);
  }
}

TypeMatcher<List<int>> decodedMatches(dynamic string) {
  return isA<List<int>>().having((e) => utf8.decode(e), 'decoded', string);
}
