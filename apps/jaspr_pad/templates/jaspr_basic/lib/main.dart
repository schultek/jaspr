import 'package:jaspr/browser.dart';

void main() {
  runApp(DomComponent(
    tag: 'h1',
    child: Text('Hello World!'),
  ));
}