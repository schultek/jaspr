import 'package:jaspr/server.dart';

import 'app.dart';{{#hydration}}
import 'jaspr_options.dart';{{/hydration}}
import 'styles.dart';

void main() {
  Jaspr.initializeApp({{#hydration}}
    options: defaultJasprOptions,
  {{/hydration}});

  runApp(Document(
    title: '{{name}}',
    styles: styles,{{#flutter}}
    head: [
      link(rel: 'manifest', href: 'manifest.json'),
    ],{{/flutter}}
    body: App(),
  ));
}
