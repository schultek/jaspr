import 'package:jaspr/server.dart';

import 'components/app.dart';

/// Entrypoint for the server
void main() async {
  // Jaspr.initializeApp(
  //   options: defaultJasprOptions,
  // );

  runApp(
    Document(body: App()),
  );
}
