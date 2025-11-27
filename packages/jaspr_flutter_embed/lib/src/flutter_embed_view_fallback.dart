import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'view_constraints.dart';
import 'widget.dart';

class FlutterEmbedView extends StatelessComponent {
  const FlutterEmbedView({this.id, this.classes, this.styles, this.constraints, this.loader, this.widget, super.key})
    : loadLibrary = null,
      builder = null;

  const FlutterEmbedView.deferred({
    this.id,
    this.classes,
    this.styles,
    this.constraints,
    this.loader,
    this.loadLibrary,
    this.builder,
    super.key,
  }) : widget = null;

  final String? id;
  final String? classes;
  final Styles? styles;
  final ViewConstraints? constraints;
  final Component? loader;
  final Future<void>? loadLibrary;
  final Widget? widget;

  final Object Function()? builder;

  static Future<void> preload() => Future.value();

  @override
  Component build(BuildContext context) {
    return div(
      id: id,
      classes: classes,
      styles: Styles.combine([
        if (constraints case final c?)
          Styles(
            minWidth: c.minWidth != double.infinity ? c.minWidth?.px : null,
            maxWidth: c.maxWidth != double.infinity ? c.maxWidth?.px : null,
            minHeight: c.minHeight != double.infinity ? c.minHeight?.px : null,
            maxHeight: c.maxHeight != double.infinity ? c.maxHeight?.px : null,
          ),
        ?styles,
      ]),
      [?loader],
    );
  }
}
