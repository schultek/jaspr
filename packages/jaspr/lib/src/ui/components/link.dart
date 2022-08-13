import 'package:jaspr/src/ui/components/base.dart';

class Link extends BaseComponent {
  final String href;
  final bool openInNewTab;

  const Link({
    required this.href,
    this.openInNewTab = false,
    super.key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
    super.child,
    super.children,
  }) : super(tag: 'a');

  @override
  Map<String, String> getAttributes() => {
        "href": href,
        if (openInNewTab) "target": "_blank",
        ...super.attributes ?? {},
      };
}