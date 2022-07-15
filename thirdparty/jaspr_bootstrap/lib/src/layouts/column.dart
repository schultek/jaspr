import 'package:jaspr_bootstrap/core.dart';
import 'package:jaspr_bootstrap/src/components/base.dart';

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
    super.style,
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
  List<String> getClasses([List<String>? classes]) {
    return [
      ...flexibility.map((e) => e.getClass('col')),
      ...super.getClasses(classes),
    ];
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
