import 'dart:async';

import 'package:jaspr/jaspr.dart';

import '../services/service.dart';
import 'button.dart';

class Counter extends StatefulComponent {
  Counter({Key? key}) : super(key: key);

  @override
  State<StatefulComponent> createState() => CounterState();
}

class CounterState extends State<Counter> with PreloadStateMixin<Counter>, SyncStateMixin<Counter, int> {
  int counter = 0;

  @override
  String get syncId => 'counter';

  @override
  int saveState() {
    return counter;
  }

  @override
  void updateState(int? value) {
    counter = value ?? counter;
    setState(() {});
  }

  @override
  Future<void> preloadState() async {
    // fetch some data, only executed on the server
    counter = await DataService.instance!.getData();
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Button(
      label: 'Click Me',
      onPressed: () {
        setState(() => counter++);
      },
    );

    yield DomComponent(
      tag: 'span',
      child: Text('Counter: $counter'),
    );
  }
}
