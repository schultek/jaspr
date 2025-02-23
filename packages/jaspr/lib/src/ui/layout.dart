import '../../jaspr.dart';

class Page extends StatelessComponent {
  const Page({super.key, this.overflow = Overflow.initial, this.children = const []});

  final Overflow overflow;
  final List<Component> children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(
      styles: Styles(overflow: overflow),
      children,
    );
  }
}

class Center extends StatelessComponent {
  const Center({super.key, this.children = const []});

  final List<Component> children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(
      styles: Styles(
        display: Display.flex,
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
      ),
      children,
    );
  }
}

class Spacer extends StatelessComponent {
  const Spacer({super.key, this.width, this.height});

  final Unit? width;
  final Unit? height;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(styles: Styles(width: width, height: height), []);
  }
}

class Padding extends StatelessComponent {
  const Padding({
    super.key,
    required this.padding,
    required this.children,
  });

  final Spacing padding;
  final List<Component> children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(styles: Styles(padding: padding), children);
  }
}

class Container extends StatelessComponent {
  const Container({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.overflow,
    this.color,
    this.border,
    this.center = false,
    this.children = const [],
  });

  final Unit? width;
  final Unit? height;
  final Spacing? padding;
  final Spacing? margin;
  final Overflow? overflow;
  final Color? color;
  final Border? border;
  final bool center;
  final List<Component> children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(
      styles: Styles.combine([
        Styles(
          width: width,
          height: height,
          padding: padding,
          margin: margin,
          overflow: overflow,
          border: border,
          backgroundColor: color,
        ),
        if (center)
          Styles(
            display: Display.flex,
            justifyContent: JustifyContent.center,
            alignItems: AlignItems.center,
          ),
      ]),
      children,
    );
  }
}

class Column extends StatelessComponent {
  const Column({
    super.key,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    required this.children,
  });

  final JustifyContent? mainAxisAlignment;
  final AlignItems? crossAxisAlignment;
  final List<Component> children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(
      styles: Styles(
        display: Display.flex,
        flexDirection: FlexDirection.column,
        flexWrap: FlexWrap.nowrap,
        justifyContent: mainAxisAlignment,
        alignItems: crossAxisAlignment,
      ),
      children,
    );
  }
}

class Row extends StatelessComponent {
  const Row({
    super.key,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    required this.children,
  });

  final JustifyContent? mainAxisAlignment;
  final AlignItems? crossAxisAlignment;
  final List<Component> children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(
      styles: Styles(
        display: Display.flex,
        flexDirection: FlexDirection.row,
        flexWrap: FlexWrap.nowrap,
        justifyContent: mainAxisAlignment,
        alignItems: crossAxisAlignment,
      ),
      children,
    );
  }
}

class Grid extends StatelessComponent {
  const Grid({
    required this.columns,
    this.gap,
    this.spread = false,
    required this.children,
  });

  final int columns;
  final Unit? gap;
  final bool spread;
  final List<Component> children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(
      styles: Styles(raw: {
        "display": "grid",
        "grid-template-columns": "repeat($columns, ${spread ? "1fr" : "0fr"})",
        if (gap != null) "gap": gap!.value,
      }),
      children,
    );
  }
}
