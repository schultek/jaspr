import 'package:flutter/widgets.dart' as flt;
import 'package:jaspr/browser.dart';
import 'package:web/web.dart' as web;

import 'run_flutter_app.dart';

export 'run_flutter_app.dart' show ViewConstraints;

class FlutterEmbedView extends StatefulComponent {
  const FlutterEmbedView({
    this.app,
    this.loader,
    this.constraints,
    this.id,
    this.classes,
    this.styles,
    super.key,
  });

  final flt.Widget? app;
  final Component? loader;
  final ViewConstraints? constraints;
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
        element = element.children.item(element.children.length - 1)!;
        viewId = await addView(element, component.constraints, flt.StatefulBuilder(builder: (context, setState) {
          rebuildFlutterApp = () => setState(() {});
          waitOnWarmupFrames();
          return component.app ?? flt.SizedBox.shrink();
        }));
      });
    }
  }

  int frame = 0;
  void waitOnWarmupFrames() {
    if (frame > 2) {
      setState(() {});
      return;
    }
    flt.WidgetsBinding.instance.addPostFrameCallback((_) {
      frame++;
      waitOnWarmupFrames();
    });
  }

  @override
  void dispose() {
    if (viewId != null) {
      removeView(viewId!);
    }
    super.dispose();
  }

  web.Element? findChildDomElement(Element element) {
    web.Node? node;
    element.visitChildren((child) {
      if (node != null) return;
      if (child is RenderObjectElement) {
        node = (child.renderObject as DomRenderObject).node as web.Element;
        return;
      } else {
        node = findChildDomElement(child);
      }
    });
    return node as web.Element?;
  }

  @override
  void didUpdateComponent(covariant FlutterEmbedView oldComponent) {
    super.didUpdateComponent(oldComponent);
    rebuildFlutterApp?.call();
  }

  final flutterDivKey = UniqueKey();

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(
      id: component.id,
      classes: component.classes,
      styles: Styles.combine([
        if (component.constraints case final c?)
          Styles.box(
            minWidth: c.minWidth != double.infinity ? c.minWidth?.px : null,
            maxWidth: c.maxWidth != double.infinity ? c.maxWidth?.px : null,
            minHeight: c.minHeight != double.infinity ? c.minHeight?.px : null,
            maxHeight: c.maxHeight != double.infinity ? c.maxHeight?.px : null,
          ),
        if (component.styles != null) component.styles!
      ]),
      [
        if (component.loader != null && frame <= 2) component.loader!,
        div(key: flutterDivKey, []),
      ],
    );
  }
}
