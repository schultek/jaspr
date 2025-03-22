import 'package:jaspr/jaspr.dart';

import '../jaspr_content.dart';

/// A post break component.
class PostBreak extends StatelessComponent {
  const PostBreak({
    super.key,
  });

  static ComponentFactory factory = ComponentFactory(
    pattern: 'PostBreak',
    build: (_, __, ___) {
      return PostBreak();
    },
  );

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'postbreak', [
      span([]),
      span([]),
      span([]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
        css('.postbreak', [
          css('&').styles(
            margin: Margin.only(top: 3.rem, bottom: 3.rem),
            display: Display.flex,
            justifyContent: JustifyContent.center,
            gap: Gap(column: 1.25.rem),
          ),
          css('span').styles(
            width: 4.px,
            height: 4.px,
            backgroundColor: Color.variable('--content-headings'),
            radius: BorderRadius.circular(4.px),
          ),
        ])
      ];
}
