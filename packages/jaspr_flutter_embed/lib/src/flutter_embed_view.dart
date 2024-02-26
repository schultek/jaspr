import 'package:flutter/widgets.dart' as flt;
import 'package:jaspr/jaspr.dart';

import 'run_flutter_app.dart';

class FlutterEmbedView extends StatefulComponent {
  const FlutterEmbedView({required this.app, this.loader, this.classes, this.styles, super.key});

  final flt.Widget app;
  final Component? loader;
  final String? classes;
  final Styles? styles;

  @override
  State<FlutterEmbedView> createState() => _FlutterEmbedViewState();
}

class _FlutterEmbedViewState extends State<FlutterEmbedView> {
  void Function()? rebuildFlutterApp;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      Future.microtask(() {
        runFlutterApp(
          attachTo: '#flutter_target',
          runApp: () {
            flt.runApp(flt.StatefulBuilder(builder: (context, setState) {
              rebuildFlutterApp = () => setState(() {});
              return component.app;
            }));
          },
        );
      });
    }
  }

  @override
  void didUpdateComponent(covariant FlutterEmbedView oldComponent) {
    super.didUpdateComponent(oldComponent);
    rebuildFlutterApp?.call();
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(id: 'flutter_target', classes: component.classes, styles: component.styles, [
      if (component.loader != null) component.loader!,
    ]);
  }
}
