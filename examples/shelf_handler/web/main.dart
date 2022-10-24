import 'dart:html';

import 'package:jaspr/jaspr.dart';
import 'package:shelf_handler/components/app.dart';
import 'package:shelf_handler/components/hello.dart';

void main() {
  if (window.location.pathname == '/hello') {
    runApp(Hello());
  } else {
    runApp(App());
  }
}
