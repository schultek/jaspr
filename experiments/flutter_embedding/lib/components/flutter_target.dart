import 'package:jaspr/html.dart';

class FlutterTarget extends StatelessComponent {
  const FlutterTarget({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield article([
      div(id: 'flutter_target', []),
    ]);
  }
}
