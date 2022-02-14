import 'dart:async';

import 'package:jaspr/jaspr.dart';

import '../services/service.dart';
import 'button.dart';

class Counter extends StatefulComponent {
  Counter({Key? key}) : super(key: key ?? StateKey(id: 'counter'));

  @override
  State<StatefulComponent> createState() => CounterState();
}

class CounterState extends State<Counter> with PreloadStateMixin<Counter, int> {
  int counter = 0;

  @override
  Future<int> preloadState() async {
    // fetch some data, only executed on the server
    return DataService.instance!.getData();
  }

  @override
  void initState() {
    super.initState();
    counter = preloadedState ?? 0;
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
