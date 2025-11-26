import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div([Component.text('App'), Counter()]);
  }
}

class Counter extends StatefulComponent {
  Counter({super.key});

  @override
  State<StatefulComponent> createState() => CounterState();
}

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
  void updateState(int? value) => throw UnimplementedError();

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      Button(
        label: 'Click Me',
        onPressed: () {
          setState(() => counter++);
        },
      ),
      Component.text('Count: $counter'),
    ]);
  }
}

class Button extends StatelessComponent {
  const Button({required this.label, required this.onPressed});

  final String label;
  final void Function() onPressed;

  @override
  Component build(BuildContext context) {
    return button(events: {'click': (e) => onPressed()}, [Component.text(label)]);
  }
}
