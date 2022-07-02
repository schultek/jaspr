import 'package:jaspr/src/ui/elements/base.dart';
import 'package:jaspr/src/ui/styles.dart';

class BoxConstraints {
  final Unit? maxWidth;
  final Unit? maxHeight;
  final Unit? minWidth;
  final Unit? minHeight;

  const BoxConstraints({this.maxWidth, this.maxHeight, this.minWidth, this.minHeight});

  static const BoxConstraints zero = BoxConstraints();
}

class ConstrainedBox extends BaseElement {
  final BoxConstraints constraints;

  const ConstrainedBox({
    required this.constraints,
    super.key,
    super.id,
    super.style,
    super.classes,
    super.attributes,
    super.events,
    super.child,
    super.children,
  }) : super(tag: 'div');

  @override
  BaseStyle? getStyles() => MultipleStyle(styles: [
    if (constraints.maxWidth != null) Style('max-width', constraints.maxWidth.toString()),
    if (constraints.maxHeight != null) Style('max-height', constraints.maxHeight.toString()),
    if (constraints.minWidth != null) Style('min-width', constraints.minWidth.toString()),
    if (constraints.minHeight != null) Style('min-height', constraints.minHeight.toString()),
  ]);
}

class Size extends BaseElement {
    final Unit? width;
    final Unit? height;

    const Size({
    this.width,
    this.height,
    super.key,
    super.id,
    super.style,
    super.classes,
    super.attributes,
    super.events,
    super.child,
    super.children,
  }) : super(tag: 'div');

  @override
  BaseStyle? getStyles() => MultipleStyle(styles: [
    if (width != null) Style('width', width.toString()),
    if (height != null) Style('height', height.toString()),
  ]);
}
