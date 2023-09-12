import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
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

const sync = Object();

mixin _$CounterState on State<Counter> implements SyncState<Map<String, dynamic>> {
  int get counter;
  set counter(int c);

  @override
  Map<String, dynamic> getState() {
    return {'counter': counter};
  }

  @override
  String get syncId => r'CounterState#123';

  @override
  void updateState(Map<String, dynamic>? state) {
    if (state == null) return;
    if (state.containsKey('counter')) {
      counter = state['counter'];
    }
  }

  @override
  final syncCodec = CastCodec();

  @override
  bool wantsSync() => true;

  @override
  void initState() {
    super.initState();
    context.binding.registerSyncState(this, initialUpdate: context.binding.isClient);
  }

  @override
  void dispose() {
    context.binding.unregisterSyncState(this);
    super.dispose();
  }
}

@sync
class CounterState extends State<Counter> with _$CounterState {
  int counter = 0;

  @override
  Iterable<Component> build(BuildContext context) sync* {
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
