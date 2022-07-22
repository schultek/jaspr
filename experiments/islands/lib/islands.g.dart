import 'package:jaspr/islands.dart';
import 'components/counter.island.g.dart' deferred as p0;

void runIslandsApp() {
  IslandsApp.runDeferred({
    'counter': () => p0.loadLibrary().then((_) => p0.CounterIsland.instantiate),
  });
}
