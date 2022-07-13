import 'package:example/pages/paragraph_example.dart';
import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    //yield FirstPage();
    yield NewParagraphExample();

    yield OldParagraphExample();
  }
}

