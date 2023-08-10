import 'package:jaspr/html.dart';
import 'package:jaspr/server.dart';

import './app.dart';

void main() {
  runApp(Document(
    title: 'tailwind_test',
    head: [
      link(href: 'styles.css', rel: 'stylesheet'),
    ],
    body: App(),
  ));
}
