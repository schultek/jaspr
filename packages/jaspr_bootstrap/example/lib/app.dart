import 'package:example/pages/carousel_page.dart';
import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield CarouselPage();
  }
}