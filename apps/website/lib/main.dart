import 'package:jaspr/server.dart';

import 'app.dart';

import 'jaspr_options.dart';

void main() {
  Jaspr.initializeApp(options: defaultJasprOptions);

  runApp(
    Document(
      title: 'Jaspr | Dart Web Framework',
      lang: 'en',
      head: [link(rel: 'icon', type: 'image/x-icon', href: 'favicon.ico')],
      body: App(),
    ),
  );
}
