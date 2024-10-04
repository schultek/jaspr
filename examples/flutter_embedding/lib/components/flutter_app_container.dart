import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

@Import.onWeb('package:flutter_riverpod/flutter_riverpod.dart', show: [#UncontrolledProviderScope])
@Import.onWeb('../widgets/app.dart', show: [#MyApp])
import 'flutter_app_container.imports.dart' as flt;
import 'flutter_target.dart';
import 'ripple_loader.dart';

class FlutterAppContainer extends StatelessComponent {
  const FlutterAppContainer({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield FlutterTarget(
      loader: RippleLoader(),
      app: kIsWeb
          ? flt.UncontrolledProviderScope(
              container: ProviderScope.containerOf(context),
              child: flt.MyApp(),
            )
          : null,
    );
  }
}
