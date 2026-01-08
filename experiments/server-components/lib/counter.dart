import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

@client
class Counter extends StatefulComponent {
  const Counter({this.step = 1, this.child, super.key});

  final int step;
  final Component? child;

  @override
  State<StatefulComponent> createState() => CounterState();
}

class CounterState extends State<Counter>
    with SyncStateMixin<Counter, Map<String, dynamic>> {
  int count = 0;

  @override
  Map<String, dynamic> getState() {
    return {'stepDouble': component.step * 2};
  }

  @override
  void updateState(Map<String, dynamic> value) {
    print("GOT SYNC: $value");
  }

  @override
  Component build(BuildContext context) {
    print("Building Counter with count=$count and step=${component.step}");
    return div(classes: 'client', [
      .text('$count '),
      button(
        onClick: () {
          setState(() {
            count += component.step;
          });
        },
        [.text("Increase by ${component.step}")],
      ),
      if (component.child != null) component.child!,
      button(
        onClick: () {
          context.reload();
        },
        [.text('Reload Page')],
      ),
    ]);
  }
}
