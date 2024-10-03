@TestOn('vm')

// ignore_for_file: invalid_use_of_protected_member

import 'package:jaspr_test/jaspr_test.dart';

import '../../utils/test_component.dart';
import 'reorder_children_app.dart';

void main() {
  group('reorder children test', () {
    testComponents('should keep child state on reordering', (tester) async {
      var controller = tester.pumpTestComponent(App());
      var app = controller.element;

      expect((app.component as App).child2Key.toString(), equals('[<2>]'));

      // phase 1 (1, 2, 3): children should be mounted
      expect(find.textContaining('Child'), findsNComponents(3));

      var elements1 = app.children.whereType<ChildElement>().toList();
      expect(elements1.map((e) => e.component.num), equals([1, 2, 3]));

      // phase 2 (2): children should be reordered
      await controller.rebuildWith(2);

      expect(find.textContaining('Child'), findsNComponents(1));

      // all elements should be reused
      var elements2 = app.children.whereType<ChildElement>().toList();
      expect(elements2, equals([elements1[1]]));

      // phase 3 (3, 2): children should be reordered
      await controller.rebuildWith(3);

      expect(find.textContaining('Child'), findsNComponents(2));

      // first element should be created and second element reused
      var elements3 = app.children.whereType<ChildElement>().toList();
      expect(elements3[0].component.num, equals(3));
      expect(elements3[1], equals(elements1[1]));

      // phase 4 (1, 3, 2): children should be reordered
      await controller.rebuildWith(4);

      expect(find.textContaining('Child'), findsNComponents(3));

      // first element should be created and other elements reused
      var elements4 = app.children.whereType<ChildElement>().toList();
      expect(elements4[0].component.num, equals(1));
      expect(elements4.skip(1), equals([elements3[0], elements1[1]]));
    });
  });
}
