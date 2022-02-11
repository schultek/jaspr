import 'dart:async';

import 'package:dart_web/dart_web.dart';

import '../service.dart';
import 'button.dart';

class Counter extends StatefulComponent {
  Counter() : super(key: StateKey(id: 'counter'));

  @override
  State<StatefulComponent> createState() => CounterState();
}

class CounterState extends State<Counter> with PreloadStateMixin<Counter, int>, PersistStateMixin<Counter, int> {
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
  void didLoadState() {
    counter = preloadedState ?? 0;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Button(
      label: 'Click Me',
      onPressed: () {
        setState(() => ++counter);
      },
    );

    if (isLoadingState) {
      yield DomComponent(tag: 'span', child: Text('LOADING'));
    } else {
      yield DomComponent(
        tag: 'span',
        child: Text('Counter: $counter'),
      );
    }
  }
}
