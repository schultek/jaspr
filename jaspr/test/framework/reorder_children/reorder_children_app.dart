import 'package:jaspr/jaspr.dart';

import '../../utils/test_component.dart';

class App extends TestComponent<int> {
  App() : super(initialValue: 1);

  final child1Key = UniqueKey();
  final child2Key = UniqueKey();
  final child3Key = UniqueKey();

  @override
  Iterable<Component> build(BuildContext context, int phase) sync* {
    if (phase == 1) {
      yield ChildComponent(
        key: child1Key,
        num: 1,
      );

      yield ChildComponent(
        key: child2Key,
        num: 2,
      );

      yield ChildComponent(
        key: child3Key,
        num: 3,
      );
    } else if (phase == 2) {
      yield ChildComponent(
        key: child2Key,
        num: 2,
      );

      yield ChildComponent(
        key: child1Key,
        num: 1,
      );
    } else if (phase == 3) {
      yield ChildComponent(
        key: child3Key,
        num: 3,
      );

      yield ChildComponent(
        key: child2Key,
        num: 2,
      );
    } else {
      yield ChildComponent(
        key: child1Key,
        num: 1,
      );

      yield ChildComponent(
        key: child3Key,
        num: 3,
      );

      yield ChildComponent(
        key: child2Key,
        num: 2,
      );
    }
  }
}

class ChildComponent extends Component {
  ChildComponent({Key? key, required this.num}) : super(key: key);

  final int num;

  @override
  Element createElement() => ChildElement(this);
}

class ChildElement extends SingleChildElement {
  ChildElement(ChildComponent component) : super(component);

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
  Component? build() => Text('Child ${component.num}');
}
