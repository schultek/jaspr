import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/bootstrap.dart';
import 'package:jaspr_ui/src/bootstrap/components/base.dart';
import 'package:jaspr_ui/src/core/elements/div.dart';

class Column extends BaseComponent {
  final Flex? _flex;
  final List<Flex>? _flexibility;

  const Column({
    Flex? flex,
    List<Flex>? flexibility,
    super.id,
    super.key,
    super.child,
    super.children,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
    super.backgroundColor,
    super.textColor,
    super.padding,
    super.margin,
    super.border,
  })  : _flex = flex,
        _flexibility = flexibility;

  List<Flex> get flexibility {
    final List<Flex> result = [if (_flex != null) _flex!, ..._flexibility ?? []];
    return result.isEmpty ? [Flex()] : result;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DivElement(
      id: id,
      styles: styles,
      attributes: attributes,
      events: events,
      classes: [
        ...flexibility.map((e) => e.getClass('col')),
        ...getClasses(classes),
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
