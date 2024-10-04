import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'effects_controls.dart';
import 'flutter_app_container.dart';
import 'interop_controls.dart';

@client
class App extends StatelessComponent {
  const App({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield ProviderScope(
      child: section(classes: 'contents', [
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
