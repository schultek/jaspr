import 'package:jaspr/jaspr.dart';

import '../jaspr_content.dart';

/// A drop cap component that renders the first letter of a paragraph in a larger font size.
class DropCap extends StatelessComponent with CustomComponentBase {
  const DropCap();

  @override
  final Pattern pattern = 'DropCap';

  @override
  Component apply(String name, Map<String, String> attributes, Component? child) {
    return this;
  }

  @override
  Component build(BuildContext context) {
    return span(classes: 'dropcap', []);
  }

  @css
  static List<StyleRule> get styles => [
    css('.dropcap + p:first-letter').styles(
      fontSize: 5.em,
      lineHeight: 0.85.em,
      margin: Margin.only(right: 0.1.em, bottom: 0.1.em),
      raw: {'float': 'left'},
    ),
  ];
}
