import 'package:jaspr/server.dart';
import './app.dart';

void main() {
  runApp(Document.file(
    name: 'index.html',
    attachTo: 'body',
    child: App(),
  ));
}
