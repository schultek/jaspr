import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/bootstrap.dart';

class Column extends StatelessComponent {
  final BackgroundColor? backgroundColor;
  final TextColor? textColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Border? border;

  final Component? _child;
  final List<Component>? _children;
  final Flex? _flex;
  final List<Flex>? _flexibility;

  const Column({
    Key? key,
    Component? child,
    List<Component>? children,
    Flex? flex,
    List<Flex>? flexibility,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.margin,
    this.border,
  })  : _child = child,
        _children = children,
        _flex = flex,
        _flexibility = flexibility,
        super(key: key);

  List<Component> get children => [if (_child != null) _child!, ..._children ?? []];

  List<Flex> get flexibility {
    final List<Flex> result = [if (_flex != null) _flex!, ..._flexibility ?? []];
    return result.isEmpty ? [Flex()] : result;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: [
        ...flexibility.map((e) => e.getClass('col')),
        if (backgroundColor != null) backgroundColor!.value,
        if (textColor != null) textColor!.value,
        if (padding != null) ...padding!.getClasses('p'),
        if (margin != null) ...margin!.getClasses('m'),
        if (border != null) ...border!.getClasses(),
      ],
      children: children,
    );
  }
}

class Flex {
  final Breakpoint breakpoint;
  final ColumnSpace space;

  const Flex({
    this.breakpoint = Breakpoint.extraSmall,
    this.space = ColumnSpace.auto,
  });

  String getClass(String type) => space == ColumnSpace.auto ? type : '$type${breakpoint.value}-${space.value}';
}
