import 'package:jaspr/jaspr.dart';

class MdNavigationBar extends StatelessComponent {
  const MdNavigationBar({
    this.activeIndex = 0,
    this.hideInactiveLabels = false,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final double activeIndex;
  final bool hideInactiveLabels;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-navigation-bar.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-navigation-bar',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        'active-index': '$activeIndex',
        if (hideInactiveLabels) 'hide-inactive-labels': '',
      },
      events: events,
      children: children,
    );
  }
}
  