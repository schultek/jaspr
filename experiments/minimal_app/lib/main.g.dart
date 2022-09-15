// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'main.dart' as e;
import 'package:minimal_app_experiment/app.dart' as c0;

void main() {
  ComponentRegistry.initialize('main', components: {
    c0.App: ComponentEntry<c0.App>.app('app', getParams: (c) {
      return {'numCounters': c.numCounters};
    }),
  });
  e.main();
}
