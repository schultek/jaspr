// [sample][hidden] Tutorial
import 'package:jaspr/browser.dart';

void main() {
  runApp(DomComponent(
    tag: 'div',
    children: [
      DomComponent(
        tag: 'h1',
        child: Text('Hello World!'),
      ),
      DomComponent(
        tag: 'p',
        child: Text('You\'re great!'),
      ),
    ],
  ));
}
