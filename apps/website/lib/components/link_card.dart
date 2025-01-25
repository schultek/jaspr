import 'package:jaspr/jaspr.dart';
import 'package:website/constants/theme.dart';

import 'icon.dart';

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
      span(classes: 'card-icon', [Icon(icon)]),
      h5([text(title)]),
      p([text(description)]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('.link-card', [
      css('&')
          .box(
            radius: BorderRadius.circular(12.px),
            border: Border.all(BorderSide.solid(width: 2.px, color: Color.hex('#EEE'))),
            padding: EdgeInsets.all(1.rem),
            shadow: BoxShadow(offsetX: 1.px, offsetY: 1.px, blur: 3.px, spread: (-1).px, color: Color.hex('#0001')),
          )
          .flexbox(direction: FlexDirection.column, alignItems: AlignItems.stretch)
          .text(align: TextAlign.start, decoration: TextDecoration.none),
      css('&:hover').background(color: Color.hex('#F5F5F5')).box(
            border: Border.all(BorderSide(color: primaryMid, width: 2.px)),
            cursor: Cursor.pointer,
          ),
      css('.card-icon').text(fontSize: 1.5.em, color: primaryMid).box(margin: EdgeInsets.only(bottom: 1.rem)),
      css('p').box(margin: EdgeInsets.only(top: 0.4.em, bottom: Unit.zero)).combine(bodySmall),
    ]),
  ];
}
