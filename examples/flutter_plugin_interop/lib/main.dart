import 'package:flutter_plugin_interop/jaspr_options.dart';
import 'package:jaspr/server.dart';

import 'components/app.dart';

void main() {
  Jaspr.initializeApp(options: defaultJasprOptions);

  runApp(Document(
    title: "Flutter Plugin Interop",
    head: [
      link(rel: "stylesheet", href: "styles.css"),
    ],
    body: App(),
  ));
}
