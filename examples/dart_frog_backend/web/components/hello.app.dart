// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/browser.dart';
import 'package:dart_frog_backend/components/hello.dart' as a;

void main() {
  runAppWithParams(getComponentForParams);
}

Component getComponentForParams(ConfigParams p) {
  return a.Hello(name: p.get('name'));
}
