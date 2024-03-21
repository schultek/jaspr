import 'package:jaspr/jaspr.dart';

import 'ripple_loader.dart';

class FlutterAppContainer extends StatelessComponent {
  const FlutterAppContainer({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield article([
      div(id: 'flutter_target', [
        RippleLoader(),
      ])
    ]);
  }
}
