import 'package:jaspr/jaspr.dart';

class AsyncStatelessComponent extends StatelessComponent {}

class App extends AsyncStatelessComponent {
  @override
  Stream<Component> build(BuildContext context) async* {
    yield DomComponent(tag: 'div', children: [
      Text('App'),
      Counter(),
    ]);
  }
}

class Counter extends StatefulComponent {
  Counter({Key? key}) : super(key: key);

  @override
  State<StatefulComponent> createState() => CounterState();
}

@sync
class CounterState extends State<Counter> with PreloadStateMixin, SyncStateMixin<Counter, int> {
  int counter = 0;

  @override
  Future<void> preloadState() {
    return Future.delayed(Duration(milliseconds: 10), () {
      counter = 202;
    });
  }

  @override
  int getState() => counter;

  @override
  String get syncId => 'counter';

  @override
  void updateState(int? value) => throw UnimplementedError();

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (!kIsWeb) {
      counter = context.load(() async {
        await Future.delayed(Duration(milliseconds: 10));
        return 202;
      });
    }

    yield Button(
      label: 'Click Me',
      onPressed: () {
        setState(() => counter++);
      },
    );

    yield Text('Count: $counter');
  }
}

class Button extends StatelessComponent {
  const Button({required this.label, required this.onPressed});

  final String label;
  final void Function() onPressed;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'button',
      child: Text(label),
      events: {'click': (e) => onPressed()},
    );
  }
}
