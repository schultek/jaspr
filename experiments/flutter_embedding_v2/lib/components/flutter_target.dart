import 'package:element_embedding_demo/providers/effects_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as fr;
import 'package:jaspr/html.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../embedding/flutter_embed_view.dart';
import '../widgets/app.dart';

class FlutterTarget extends StatelessComponent {
  const FlutterTarget({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var effects = context.watch(effectsProvider);
    var rotation = context.watch(rotationProvider);

    var isHandheld = effects.contains('handheld');

    Component child = FlutterEmbedView(
      key: GlobalObjectKey('flutter_target'),
      classes: isHandheld ? ['handheld'] : effects.toList(),
      styles: rotation != 0
          ? Styles.box(
              transform: Transform.combine([
                Transform.perspective(1000.px),
                Transform.rotateAxis(y: rotation.deg),
              ]),
            )
          : null,
      app: fr.ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: MyApp(),
      ),
    );

    if (isHandheld) {
      child = div(id: 'handheld', [
        child,
        span(classes: [
          'imageAttribution'
        ], [
          text('Photo by '),
          a(
            href: 'https://unsplash.com/photos/x9WGMWwp1NM',
            target: Target.blank,
            attributes: {'rel': 'noopener noreferrer'},
            [text('Nathana Rebouças')],
          ),
          text(' on Unsplash'),
        ]),
      ]);
    }

    yield article([child]);
  }
}
