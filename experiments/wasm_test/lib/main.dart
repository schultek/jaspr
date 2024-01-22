import 'package:jaspr/server.dart';

import 'app.dart';

void main() {
  runApp(Document(
    scriptName: 'main',
    body: App(),
  ));
}
