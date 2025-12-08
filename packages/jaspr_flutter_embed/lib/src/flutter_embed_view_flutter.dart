import 'package:flutter/widgets.dart' as flt;
import 'package:jaspr/client.dart';
import 'package:jaspr/dom.dart';
import 'package:web/web.dart' as web;

import 'run_flutter_app.dart';
import 'view_constraints.dart';

class FlutterEmbedView extends StatefulComponent {
  const FlutterEmbedView({
    this.id,
    this.classes,
    this.styles,
    this.constraints,
    this.loader,
    this.widget,
    super.key,
  });

  final flt.Widget? widget;
  final Component? loader;
  final ViewConstraints? constraints;
  final String? id;
  final String? classes;
  final Styles? styles;

  static Future<void> preload() => preloadEngine();

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
        viewId = await addView(
          element,
          component.constraints,
          flt.StatefulBuilder(
            builder: (context, setState) {
              rebuildFlutterApp = () {
                if (!context.mounted) return;
                setState(() {});
              };
              waitOnWarmupFrames();
              return component.widget ?? flt.SizedBox.shrink();
            },
          ),
        );
      });
    }
  }

  // The flutter view does only actually appear after the second frame.
  // We delay the removal of the loader component until then.
  bool get didRenderView => _frame > 1;
  int _frame = 0;

  void waitOnWarmupFrames() {
    if (!mounted) return;
    if (_frame > 1) {
      setState(() {});
      return;
    }
    flt.WidgetsBinding.instance.addPostFrameCallback((_) {
      _frame++;
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
  Component build(BuildContext context) {
    return div(
      id: component.id,
      classes: [if (component.classes != null) component.classes, if (didRenderView) 'active'].join(' '),
      styles: Styles.combine([
        if (component.constraints case final c?)
          Styles(
            minWidth: c.minWidth != double.infinity ? c.minWidth?.px : null,
            maxWidth: c.maxWidth != double.infinity ? c.maxWidth?.px : null,
            minHeight: c.minHeight != double.infinity ? c.minHeight?.px : null,
            maxHeight: c.maxHeight != double.infinity ? c.maxHeight?.px : null,
          ),
        if (component.styles != null) component.styles!,
      ]),
      [
        if (component.loader != null && !didRenderView) component.loader!,
        div(
          key: flutterDivKey,
          styles: Styles(height: 100.percent),
          [],
        ),
      ],
    );
  }
}
