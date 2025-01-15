import 'package:jaspr/server.dart';

import 'app.dart';

import 'jaspr_options.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultJasprOptions,
  );

  runApp(Document(
    title: 'Jaspr Web Framework',
    body: App(),
  ));
}
