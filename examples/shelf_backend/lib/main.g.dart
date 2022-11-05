// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'main.dart' as e;
import 'package:shelf_handler/components/app.dart' as c0;
import 'package:shelf_handler/components/hello.dart' as c1;

void main() {
  ComponentRegistry.initialize('main', components: {
    c0.App: ComponentEntry.app('components/app'),
    c1.Hello: ComponentEntry.app('components/hello'),
  });
  e.main();
}
