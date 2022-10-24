// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/browser.dart';
import 'package:islands_app/counter.dart' deferred as c0;

void main() {
  runIslandsDeferred({
    'counter': loadIsland(c0.loadLibrary, (p) {
      return c0.Counter(initialValue: p.get('initialValue'), someText: p.get('someText'));
    }),
  });
}
