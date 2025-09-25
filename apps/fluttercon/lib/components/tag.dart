import 'package:jaspr/jaspr.dart';

class Tag extends StatelessComponent {
  const Tag({required this.label, super.key});

  final String label;

  @override
  Component build(BuildContext context) {
    return span(classes: "tag", [text(label)]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.tag').styles(
      padding: Padding.symmetric(horizontal: 0.4.em, vertical: 0.2.em),
      margin: Margin.symmetric(horizontal: 2.px),
      border: Border(color: Colors.black, width: 1.px),
      radius: BorderRadius.circular(0.7.em),
    ),
  ];
}
