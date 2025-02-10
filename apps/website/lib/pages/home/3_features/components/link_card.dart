import 'package:jaspr/jaspr.dart';
import 'package:website/constants/theme.dart';

import '../../../../components/gradient_border.dart';
import '../../../../components/icon.dart';

class LinkCard extends StatelessComponent {
  const LinkCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.link,
    super.key,
  });

  final String icon;
  final String title;
  final String description;
  final String link;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield a(classes: 'link-card', href: link, [
      GradientBorder(
        radius: 12,
        child: div(classes: 'link-card-content', [
          span(classes: 'card-icon', [Icon(icon)]),
          h5([text(title)]),
          p([text(description)]),
        ]),
      ),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('.link-card', [
      css('&')
          .box(
            display: Display.block,
            border: Border.all(BorderSide(width: 2.px, color: borderColor)),
            radius: BorderRadius.circular(13.px),
            shadow: BoxShadow(
              offsetX: 1.px,
              offsetY: 1.px,
              blur: 3.px,
              spread: (-1).px,
              color: shadowColor1,
            ),
            transition: Transition('background', duration: 300),
          )
          .text(align: TextAlign.start, decoration: TextDecoration.none),
      css('&:hover').background(color: surface),
      css('.link-card-content')
          .box(
            radius: BorderRadius.circular(10.px),
            padding: EdgeInsets.all(1.rem),
          )
          .flexbox(direction: FlexDirection.column, alignItems: AlignItems.stretch),
      css('.card-icon').text(fontSize: 1.5.em, color: primaryMid).box(margin: EdgeInsets.only(bottom: 1.rem)),
      css('p').box(margin: EdgeInsets.only(top: 0.4.em, bottom: Unit.zero)).combine(bodySmall),
    ]),
  ];
}
