import 'package:jaspr/server.dart';

import 'app.dart';

void main() async {
  // runs the app component on both server and client
  runApp(Document.app(body: App()));
}
