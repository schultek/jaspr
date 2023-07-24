import 'package:jaspr/html.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'effects_controls.dart';
import 'flutter_app_container.dart' if (dart.library.html) 'flutter_app_container.dart';
import 'interop_controls.dart';

class App extends StatelessComponent {
  const App({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield ProviderScope(
      child: section(classes: [
        'contents'
      ], [
        FlutterAppContainer(),
        aside(id: 'demo_controls', [
          h1([text('Element embedding')]),
          EffectsControls(),
          InteropControls(),
        ]),
      ]),
    );
  }
}
