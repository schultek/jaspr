import 'package:jaspr/jaspr.dart';

import '../jaspr_content.dart';

/// A drop cap component.
class DropCap extends StatelessComponent {
  const DropCap({
    super.key,
  });

  static ComponentFactory factory = ComponentFactory(
    pattern: 'DropCap',
    build: (_, __, ___) {
      return DropCap();
    },
  );

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield span(classes: 'dropcap', []);
  }

  @css
  static List<StyleRule> get styles => [
        css('.dropcap + p:first-letter').styles(
          fontSize: 5.rem,
          lineHeight: 0.85.em,
          margin: Margin.only(right: 0.1.em, bottom: 0.1.em),
          raw: {
            'float': 'left',
          },
        ),
      ];
}
