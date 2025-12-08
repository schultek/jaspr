import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../components/gradient_border.dart';
import '../../../../components/icon.dart';
import '../../../../constants/theme.dart';

class LinkCard extends StatelessComponent {
  const LinkCard({required this.icon, required this.title, required this.description, required this.link, super.key});

  final String icon;
  final String title;
  final String description;
  final String link;

  @override
  Component build(BuildContext context) {
    return a(classes: 'link-card', href: link, [
      GradientBorder(
        radius: 12,
        child: div(classes: 'link-card-content', [
          span(classes: 'card-icon', [Icon(icon)]),
          h5([.text(title)]),
          p([.text(description)]),
        ]),
      ),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.link-card', [
      css('&').styles(
        display: .block,
        border: .all(width: 2.px, color: borderColor),
        radius: .circular(13.px),
        shadow: .new(offsetX: 1.px, offsetY: 1.px, blur: 3.px, spread: (-1).px, color: shadowColor1),
        transition: .new('background', duration: 300.ms),
        textAlign: .start,
        textDecoration: .none,
      ),
      css('&:hover').styles(backgroundColor: surface),
      css('.link-card-content').styles(
        display: .flex,
        padding: .all(1.rem),
        radius: .circular(10.px),
        flexDirection: .column,
        alignItems: .stretch,
      ),
      css('.card-icon').styles(
        margin: .only(bottom: 1.rem),
        color: primaryMid,
        fontSize: 1.5.em,
      ),
      css('p')
          .styles(
            margin: .only(top: 0.4.em, bottom: .zero),
          )
          .combine(bodySmall),
    ]),
  ];
}
