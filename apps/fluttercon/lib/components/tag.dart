import 'package:jaspr/dom.dart';

class Tag extends StatelessComponent {
  const Tag({required this.label, super.key});

  final String label;

  @override
  Component build(BuildContext context) {
    return span(classes: "tag", [.text(label)]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.tag').styles(
      padding: .symmetric(horizontal: 0.4.em, vertical: 0.2.em),
      margin: .symmetric(horizontal: 2.px),
      border: .all(color: Colors.black, width: 1.px),
      radius: .circular(0.7.em),
    ),
  ];
}
