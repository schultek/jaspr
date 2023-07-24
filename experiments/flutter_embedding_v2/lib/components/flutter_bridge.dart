import 'package:jaspr/html.dart';

class FlutterBridge extends StatelessComponent {
  const FlutterBridge({this.loader, Key? key}) : super(key: key);

  final Component? loader;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield article([
      div(id: 'flutter_target', [
        if (loader != null) loader!,
      ])
    ]);
  }
}
