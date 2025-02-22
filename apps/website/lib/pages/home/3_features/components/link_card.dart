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
      css('&').styles(
        display: Display.block,
        border: Border(width: 2.px, color: borderColor),
        radius: BorderRadius.circular(13.px),
        shadow: BoxShadow(offsetX: 1.px, offsetY: 1.px, blur: 3.px, spread: (-1).px, color: shadowColor1),
        transition: Transition('background', duration: 300),
        textAlign: TextAlign.start,
        textDecoration: TextDecoration.none,
      ),
      css('&:hover').styles(backgroundColor: surface),
      css('.link-card-content').styles(
        radius: BorderRadius.circular(10.px),
        padding: Padding.all(1.rem),
        display: Display.flex,
        flexDirection: FlexDirection.column,
        alignItems: AlignItems.stretch,
      ),
      css('.card-icon').styles(
        fontSize: 1.5.em,
        color: primaryMid,
        margin: Margin.only(bottom: 1.rem),
      ),
      css('p').styles(margin: Margin.only(top: 0.4.em, bottom: Unit.zero)).combine(bodySmall),
    ]),
  ];
}
