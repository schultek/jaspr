import 'package:islands_experiment/components/counter.dart' deferred as counter;
import 'package:jaspr/islands.dart';

void main() {
  IslandsApp.runDeferred({
    'cnt': () => counter.loadLibrary().then((_) => counter.CounterIsland()),
  });
}
