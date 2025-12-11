@TestOn('vm')
library;

// ignore_for_file: invalid_use_of_protected_member

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

import '../../utils/test_component.dart';

class ChildComponent extends Component {
  ChildComponent({super.key, required this.num});

  final int num;

  @override
  Element createElement() => ChildElement(this);
}

class ChildElement extends BuildableElement {
  ChildElement(ChildComponent super.component);

  @override
  ChildComponent get component => super.component as ChildComponent;

  @override
  void update(covariant ChildComponent newComponent) {
    if (newComponent.num != component.num) {
      throw 'Unexpected component changed num.';
    }
    super.update(newComponent);
  }

  @override
  Component build() => Component.text('Child ${component.num}');
}

void main() {
  group('reorder children test', () {
    final child1Key = UniqueKey();
    final child2Key = ValueKey(2);
    final child3Key = GlobalObjectKey(3);

    testComponents('should keep child state on reordering', (tester) async {
      final component = FakeComponent(
        child: div([
          ChildComponent(key: child1Key, num: 1),
          ChildComponent(key: child2Key, num: 2),
          ChildComponent(key: child3Key, num: 3),
        ]),
      );
      tester.pumpComponent(component);

      // phase 1 (1, 2, 3): children should be mounted
      expect(find.textContaining('Child'), findsNComponents(3));

      final divElement =
          find.descendant(of: find.byComponent(component), matching: find.tag('div')).evaluate().first
              as MultiChildElement;

      final elements1 = divElement.children.whereType<ChildElement>().toList();
      expect(elements1.map((e) => e.component.num), equals([1, 2, 3]));

      // phase 2 (2): children should be reordered
      component.updateChild(div([ChildComponent(key: child2Key, num: 2)]));
      await tester.pump();

      expect(find.textContaining('Child'), findsNComponents(1));

      // all elements should be reused
      final elements2 = divElement.children.whereType<ChildElement>().toList();
      expect(elements2, equals([elements1[1]]));

      // phase 3 (3, 2): children should be reordered
      component.updateChild(div([ChildComponent(key: child3Key, num: 3), ChildComponent(key: child2Key, num: 2)]));
      await tester.pump();

      expect(find.textContaining('Child'), findsNComponents(2));

      // first element should be created and second element reused
      final elements3 = divElement.children.whereType<ChildElement>().toList();
      expect(elements3[0].component.num, equals(3));
      expect(elements3[1], equals(elements1[1]));

      // phase 4 (1, 3, 2): children should be reordered
      component.updateChild(
        div([
          ChildComponent(key: child1Key, num: 1),
          ChildComponent(key: child3Key, num: 3),
          ChildComponent(key: child2Key, num: 2),
        ]),
      );
      await tester.pump();

      expect(find.textContaining('Child'), findsNComponents(3));

      // first element should be created and other elements reused
      final elements4 = divElement.children.whereType<ChildElement>().toList();
      expect(elements4[0].component.num, equals(1));
      expect(elements4.skip(1), equals([elements3[0], elements1[1]]));
    });
  });
}
