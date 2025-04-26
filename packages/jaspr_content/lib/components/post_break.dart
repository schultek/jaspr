import 'package:jaspr/jaspr.dart';

import '../jaspr_content.dart';

/// A post break component.
class PostBreak extends StatelessComponent with CustomComponentBase {
  const PostBreak();

  @override
  final Pattern pattern = 'PostBreak';

  @override
  Component apply(String name, Map<String, String> attributes, Component? child) {
    return this;
  }

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
            backgroundColor: ContentColors.headings,
            radius: BorderRadius.circular(4.px),
          ),
        ])
      ];
}
