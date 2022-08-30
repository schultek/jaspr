import 'package:jaspr/src/ui/components/base.dart';
import 'package:jaspr/styles.dart';


class Page extends BaseComponent {
  const Page({
    this.overflow = Overflow.initial,
    super.styles,
    super.events,
    super.children,
  }) : super(tag: 'div');

  final Overflow overflow;

  @override
  Styles getStyles() => Styles.combine([
    Styles.box(overflow: overflow),
    if (styles != null) styles!
  ]);
}

class Center extends BaseComponent {
  const Center({
    super.child,
    super.children,
  }) : super(tag: 'div');

  @override
  Styles getStyles() => Styles.combine([
    Styles.flexbox(
      justifyContent: JustifyContent.center,
      alignItems: AlignItems.center,
    ),
    if (styles != null) styles!
  ]);
}

class Spacer extends BaseComponent {
  const Spacer({
    this.width,
    this.height,
  }) : super(tag: 'div');

  final Unit? width;
  final Unit? height;

  @override
  Styles getStyles() => Styles.combine([
    Styles.box(
      width: width,
      height: height,
    ),
  ]);
}

class Padding extends BaseComponent {
  const Padding({
    required this.padding,
    super.child,
  }) : super(tag: 'div');

  final EdgeInsets padding;

  @override
  Styles getStyles() => Styles.combine([
    Styles.box(padding: padding),
  ]);
}

class Container extends BaseComponent {
  const Container({
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.overflow,
    this.color,
    this.border,
    this.center = false,
    super.key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
    super.child,
  }) : super(tag: 'div');

  final Unit? width;
  final Unit? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Overflow? overflow;
  final Color? color;
  final Border? border;
  final bool center;

  @override
  Styles getStyles() => Styles.combine([
    Styles.box(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      overflow: overflow,
      border: border,
    ),
    Styles.background(color: color),
    if (center)
      Styles.flexbox(
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
      ),
    if (styles != null) styles!
  ]);
}

class Column extends BaseComponent {
  const Column({
    super.children,
  }) : super(tag: 'div');

  @override
  Styles getStyles() => Styles.combine([
    Styles.flexbox(direction: FlexDirection.column, wrap: FlexWrap.wrap),
    if (styles != null) styles!,
  ]);
}

class Row extends BaseComponent {
  const Row({
    this.wrap,
    super.children,
  }) : super(tag: 'div');

  final FlexWrap? wrap;

  @override
  Styles getStyles() => Styles.combine([
    Styles.flexbox(direction: FlexDirection.row, wrap: wrap),
    if (styles != null) styles!
  ]);
}
