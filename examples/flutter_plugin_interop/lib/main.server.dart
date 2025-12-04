import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'components/app.dart';
import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(
    Document(
      title: "Flutter Plugin Interop",
      head: [link(rel: "stylesheet", href: "styles.css")],
      body: App(),
    ),
  );
}
