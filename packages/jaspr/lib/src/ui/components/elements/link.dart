import 'package:jaspr/src/ui/components/elements/base.dart';

enum LinkTarget { blank, parent, self, top }

class Link extends BaseElement {
  final String href;
  final LinkTarget? target;

  const Link({
    required this.href,
    this.target,
    super.key,
    super.id,
    super.style,
    super.classes,
    super.attributes,
    super.events,
    super.child,
    super.children,
  }) : super(tag: 'a');

  @override
  Map<String, String> getAttributes() => {
        "href": href,
        if (target != null) "target": "_${target!.name}",
        ...super.attributes ?? {},
      };
}
