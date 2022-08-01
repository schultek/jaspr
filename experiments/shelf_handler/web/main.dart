import 'dart:html';

import 'package:jaspr/jaspr.dart';
import 'package:server_handling_experiment/components/app.dart';
import 'package:server_handling_experiment/components/hello.dart';

void main() {
  if (window.location.pathname == '/hello') {
    runApp(Hello());
  } else {
    runApp(App());
  }
}
