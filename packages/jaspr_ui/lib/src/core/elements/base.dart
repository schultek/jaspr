import 'package:jaspr/jaspr.dart';

abstract class BaseElement extends StatelessComponent {
  final String? id;
  final Map<String, String>? styles;
  final List<String>? classes;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;

  final Component? _child;
  final List<Component>? _children;

  const BaseElement({
    Key? key,
    Component? child,
    List<Component>? children,
    this.id,
    this.styles,
    this.classes,
    this.attributes,
    this.events,
  })  : _child = child,
        _children = children,
        super(key: key);

  List<Component> get children => [if (_child != null) _child!, ..._children ?? []];

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      id: id,
      styles: styles,
      classes: classes,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}
