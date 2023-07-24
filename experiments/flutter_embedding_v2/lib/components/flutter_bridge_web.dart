import 'package:jaspr/html.dart';

import '../widgets/app.dart';
import 'flutter_target.dart';

class FlutterBridge extends StatelessComponent {
  const FlutterBridge({this.loader, Key? key}) : super(key: key);

  final Component? loader;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield FlutterTarget(
      loader: loader,
      app: MyApp(),
    );
  }
}
