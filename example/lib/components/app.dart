import 'dart:async';

import 'package:dart_web/dart_web.dart';

import '../service.dart';
import 'button.dart';

class App extends StatefulComponent {
  App() : super(key: 'app');

  @override
  State<StatefulComponent, dynamic> createState() => AppState();
}

class AppState extends State<App, int> {
  int counter = 0;

  @override
  FutureOr<int?> preloadData() {
    return DataService.instance!.getData();
  }

  @override
  void initState(int? data) {
    super.initState(data);

    counter = data ?? 0;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Button(
      label: 'Click Me',
      onPressed: () => setState(() => counter++),
    );

    yield DomComponent(
      tag: 'span',
      child: Text('Counter: $counter'),
    );
  }
}
