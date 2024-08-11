import 'package:jaspr/server.dart';

import 'app.dart';
import 'jaspr_options.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultJasprOptions,
  );

  runApp(Document(
    title: '{{name}}',{{^hydration}}
    head: [
      script(defer: true, src: 'main.dart.js', []),{{#flutter}}
      link(rel: 'manifest', href: 'manifest.json'),{{/flutter}}
    ],{{/hydration}}{{#hydration}}{{#flutter}}
    head: [
      link(rel: 'manifest', href: 'manifest.json'),
    ],{{/flutter}}{{/hydration}}
    body: App(),
  ));
}
