import 'package:jaspr/jaspr.dart';

import '../../utils/test_component.dart';

class App extends TestComponent<int> {
  App() : super(initialValue: 1);

  final child1Key = UniqueKey();
  final child2Key = ValueKey(2);
  final child3Key = GlobalObjectKey(3);

  @override
  Component build(BuildContext context, int phase) {
    if (phase == 1) {
      return Fragment(children: [
        ChildComponent(
          key: child1Key,
          num: 1,
        ),
        ChildComponent(
          key: child2Key,
          num: 2,
        ),
        ChildComponent(
          key: child3Key,
          num: 3,
        ),
      ]);
    } else if (phase == 2) {
      return Fragment(children: [
        ChildComponent(
          key: child2Key,
          num: 2,
        )
      ]);
    } else if (phase == 3) {
      return Fragment(children: [
        ChildComponent(
          key: child3Key,
          num: 3,
        ),
        ChildComponent(
          key: child2Key,
          num: 2,
        ),
      ]);
    } else {
      return Fragment(children: [
        ChildComponent(
          key: child1Key,
          num: 1,
        ),
        ChildComponent(
          key: child3Key,
          num: 3,
        ),
        ChildComponent(
          key: child2Key,
          num: 2,
        ),
      ]);
    }
  }
}

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
  Component build() => Text('Child ${component.num}');
}
