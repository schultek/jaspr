import 'package:flutter/widgets.dart' as flt;
import 'package:jaspr/html.dart';

import 'flutter_loader.dart';

class FlutterEmbedView extends StatefulComponent {
  const FlutterEmbedView({required this.app, this.loaderBuilder, this.classes, this.styles, super.key});

  final flt.Widget app;
  final SingleComponentBuilder? loaderBuilder;
  final List<String>? classes;
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
        runFlutterApp(attachTo: '#flutter_target').then((_) {
          flt.runApp(flt.StatefulBuilder(builder: (context, setState) {
            rebuildFlutterApp = () => setState(() {});
            return component.app;
          }));
        });
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
    yield div([], id: 'flutter_target', classes: component.classes, styles: component.styles);
  }
}
