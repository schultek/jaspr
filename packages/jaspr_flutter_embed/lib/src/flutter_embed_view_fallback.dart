import 'package:jaspr/jaspr.dart';

typedef Widget = Never;

class ViewConstraints {
  ViewConstraints({this.minWidth, this.maxWidth, this.minHeight, this.maxHeight});

  final double? minWidth;
  final double? maxWidth;
  final double? minHeight;
  final double? maxHeight;
}

class FlutterEmbedView extends StatelessComponent {
  const FlutterEmbedView({
    this.app,
    this.loader,
    this.constraints,
    this.id,
    this.classes,
    this.styles,
    super.key,
  });

  final Widget? app;
  final Component? loader;
  final ViewConstraints? constraints;
  final String? id;
  final String? classes;
  final Styles? styles;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(
      id: id,
      classes: classes,
      styles: Styles.combine([
        if (constraints case final c?)
          Styles.box(
            minWidth: c.minWidth != double.infinity ? c.minWidth?.px : null,
            maxWidth: c.maxWidth != double.infinity ? c.maxWidth?.px : null,
            minHeight: c.minHeight != double.infinity ? c.minHeight?.px : null,
            maxHeight: c.maxHeight != double.infinity ? c.maxHeight?.px : null,
          ),
        if (styles != null) styles!
      ]),
      [
        if (loader != null) loader!,
      ],
    );
  }
}
