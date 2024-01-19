import 'package:jaspr/jaspr.dart';

class Counter extends StatefulComponent {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Text('Counter');
  }
}
