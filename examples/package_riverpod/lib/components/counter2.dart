import 'dart:math';

import 'package:jaspr/jaspr.dart';

class Counter2 extends StatefulComponent {
  const Counter2({super.key});

  @override
  State<Counter2> createState() => _Counter2State();
}

class _Counter2State extends State<Counter2> with SyncStateMixin<Counter2, int> {
  var count = Random().nextInt(100);

  @override
  void updateState(int? value) {
    print("VALUE $value");
    count = value ?? 0;
  }

  @override
  int getState() {
    return count;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield span([text('Counter: $count')]);
    yield button(onClick: () => setState(() => count++), [text('Click')]);
  }
}
