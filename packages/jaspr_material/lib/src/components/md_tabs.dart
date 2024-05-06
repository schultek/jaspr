import 'package:jaspr/jaspr.dart';

class MdTabs extends StatelessComponent {
  const MdTabs({
    required this.activeTabIndex,
    this.autoActivate = false,
    this.id, 
    this.classes, 
    this.styles, 
    this.attributes, 
    this.events, 
    this.children, 
    super.key,
  });

  final double activeTabIndex;
  final bool autoActivate;
  final String? id;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;
  final Map<String, EventCallback>? events;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(children: [
      script(src: 'packages/jaspr_material/js/md-tabs.js', async: true, []),
    ]);
    yield DomComponent(
      tag: 'md-tabs',
      id: id,
      styles: styles,
      attributes: {
        ...?attributes,
        'active-tab-index': '$activeTabIndex',
        if (autoActivate) 'auto-activate': '',
      },
      events: events,
      children: children,
    );
  }
}
  