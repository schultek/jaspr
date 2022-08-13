import 'package:jaspr/src/ui/components/base.dart';

class Link extends BaseComponent {
  final Uri target;
  final bool openInNewTab;

  const Link({
    required this.target,
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
        'href': target.toString(),
        if (openInNewTab) 'target': '_blank',
        ...super.attributes ?? {},
      };
}