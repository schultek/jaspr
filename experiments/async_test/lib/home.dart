import 'package:jaspr/html.dart';

class Home extends StatelessComponent {
  const Home({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield p([text('Home')]);
  }
}
