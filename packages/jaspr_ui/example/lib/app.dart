import 'package:example/pages.dart';
import 'package:jaspr/ui.dart';
import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield StyleElement(styles: GridSystemPage.pageStyle);
    yield GridSystemPage();
  }
}
