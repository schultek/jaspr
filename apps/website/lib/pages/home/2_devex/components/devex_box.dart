import 'package:jaspr/jaspr.dart';
import 'package:website/constants/theme.dart';

class DevexBox extends StatelessComponent {
  const DevexBox({
    required this.caption,
    required this.title,
    required this.description,
    required this.preview,
    super.key,
  });

  final String caption;
  final String title;
  final Component description;
  final Component preview;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'feature-box', [
      div(classes: 'feature-preview', [preview]),
      div(classes: 'feature-info', [
        span(classes: 'caption2 text-gradient', [text(caption)]),
        h4([text(title)]),
        p([description]),
      ])
    ]);
  }

  @css
  static List<StyleRule> get styles => [
        css('.feature-box', [
          css('&').styles(
            display: Display.flex,
            border: Border(width: 2.px, color: borderColor),
            radius: BorderRadius.circular(12.px),
            flexDirection: FlexDirection.column,
            alignItems: AlignItems.stretch,
            raw: {'background': 'linear-gradient(180deg, ${background.value} 0%, ${surface.value} 100%)'},
          ),
          css('.feature-preview').styles(minHeight: 15.rem),
          css('.feature-info', [
            css('&').styles(
              padding: Padding.only(left: 1.rem, right: 1.rem, bottom: .5.rem),
              textAlign: TextAlign.start,
            ),
          ]),
        ]),
      ];
}
