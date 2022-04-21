import 'package:jaspr/jaspr.dart';

void main() {
  runApp(() => DomComponent(
    tag: 'h1',
    child: Text('Hello World!'),
  ), id: 'app');
}