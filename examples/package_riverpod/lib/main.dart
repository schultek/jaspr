import 'package:jaspr/server.dart';

import 'app.dart';

/// Entrypoint for the server
void main() async {
  runApp(Document(body: App()));
}
