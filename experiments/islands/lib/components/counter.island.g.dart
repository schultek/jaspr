import 'package:jaspr/islands.dart';
import 'package:jaspr/jaspr.dart';
import 'counter.dart';

class CounterIsland extends IslandComponent {
  final int initialValue;

  const CounterIsland({this.initialValue = 0, super.containerBuilder, super.key}) : super(name: 'counter');

  @override
  Map<String, dynamic> get params => {'initialValue': initialValue};

  @override
  Component buildChild(BuildContext context) {
    return Counter(initialValue: initialValue);
  }

  static Component instantiate(BuildContext context, IslandParams params) {
    return Counter(initialValue: params.get('initialValue'));
  }
}
