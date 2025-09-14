import '../../jaspr.dart';

class Link extends StatelessComponent {
  const Link({super.key, required this.url, this.openInNewTab = false, required this.children});

  final Uri url;
  final bool openInNewTab;
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return a(href: url.toString(), target: openInNewTab ? Target.blank : null, children);
  }
}
