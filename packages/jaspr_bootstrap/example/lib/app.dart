import 'package:example/pages/grid_system_page.dart';
import 'package:example/pages/first_page.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/core.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield PageStyle(
      style: GridSystemPage.style,
      child: FirstPage(),
    );
  }
}
