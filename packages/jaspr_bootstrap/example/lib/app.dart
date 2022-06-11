import 'package:example/pages/grid_system_page.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_bootstrap/jaspr_bootstrap.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield PageStyle(
      style: GridSystemPage.style,
      child: GridSystemPage(),
    );
  }
}
