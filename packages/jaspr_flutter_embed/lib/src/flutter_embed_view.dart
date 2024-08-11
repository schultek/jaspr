import 'dart:html' as html;

import 'package:flutter/widgets.dart' as flt;
import 'package:jaspr/browser.dart';

import 'run_flutter_app.dart';

class FlutterEmbedView extends StatefulComponent {
  const FlutterEmbedView({required this.app, this.loader, this.id, this.classes, this.styles, super.key});

  final flt.Widget app;
  final Component? loader;
  final String? id;
  final String? classes;
  final Styles? styles;

  @override
  State<FlutterEmbedView> createState() => _FlutterEmbedViewState();
}

class _FlutterEmbedViewState extends State<FlutterEmbedView> {
  void Function()? rebuildFlutterApp;

  int? viewId;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      context.binding.addPostFrameCallback(() async {
        var element = findChildDomElement(context as Element)!;
        viewId = await addView(element, flt.StatefulBuilder(builder: (context, setState) {
          rebuildFlutterApp = () => setState(() {});
          return component.app;
        }));
      });
    }
  }

  @override
  void dispose() {
    if (viewId != null) {
      removeView(viewId!);
    }
    super.dispose();
  }

  html.Element? findChildDomElement(Element element) {
    html.Node? node;
    element.visitChildren((child) {
      if (node != null) return;
      if (child is RenderObjectElement) {
        node = (child.renderObject as DomRenderObject).node as html.Element;
        return;
      } else {
        node = findChildDomElement(child);
      }
    });
    return node as html.Element?;
  }

  @override
  void didUpdateComponent(covariant FlutterEmbedView oldComponent) {
    super.didUpdateComponent(oldComponent);
    rebuildFlutterApp?.call();
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(id: component.id, classes: component.classes, styles: component.styles, [
      if (component.loader != null) component.loader!,
    ]);
  }
}
