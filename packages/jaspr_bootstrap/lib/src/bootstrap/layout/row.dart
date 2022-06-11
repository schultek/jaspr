import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/bootstrap.dart';

class Row extends StatelessComponent {
  final BackgroundColor? backgroundColor;
  final TextColor? textColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Border? border;

  final Component? _child;
  final List<Component>? _children;

  Row({
    Key? key,
    Component? child,
    List<Component>? children,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.margin,
    this.border,
  })  : _child = child,
        _children = children,
        super(key: key);

  List<Component> get children => [if (_child != null) _child!, ..._children ?? []];

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: [
        'row',
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
