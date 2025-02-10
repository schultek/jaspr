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
  static final List<StyleRule> styles = [
    css('.feature-box', [
      css('&')
          .box(
            radius: BorderRadius.circular(12.px),
            border: Border.all(BorderSide.solid(width: 2.px, color: borderColor)),
          )
          .flexbox(direction: FlexDirection.column, alignItems: AlignItems.stretch)
          .raw({'background': 'linear-gradient(180deg, ${background.value} 0%, ${surface.value} 100%)'}),
      css('.feature-preview').box(minHeight: 15.rem),
      css('.feature-info', [
        css('&').box(padding: EdgeInsets.only(left: 1.rem, right: 1.rem, bottom: .5.rem)).text(align: TextAlign.start),
      ]),
    ]),
  ];
}
