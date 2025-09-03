import 'package:jaspr/server.dart';

import 'components/app.dart';
import 'jaspr_options.dart';

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
