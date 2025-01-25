import 'package:jaspr/jaspr.dart';
import 'package:website/constants/theme.dart';

import 'icon.dart';

class LinkButton extends StatelessComponent {
  const LinkButton._({this.label, required this.icon, required this.to, required this.style});

  final String? label;
  final String? icon;
  final String to;
  final String style;

  factory LinkButton.filled({required String label, String? icon, required String to}) {
    return LinkButton._(label: label, icon: icon, to: to, style: 'filled');
  }

  factory LinkButton.outlined({required String label, String? icon, required String to}) {
    return LinkButton._(label: label, icon: icon, to: to, style: 'outlined');
  }

  factory LinkButton.icon({required String icon, required String to}) {
    return LinkButton._(icon: icon, to: to, style: 'icon');
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield a(classes: 'link-button link-button-$style', href: to, [
      if (label != null) text(label!),
      if (icon != null) Icon(icon!),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('.link-button', [
      css('&')
          .box(
            radius: BorderRadius.circular(8.px),
            padding: EdgeInsets.symmetric(horizontal: .9.rem, vertical: .7.rem),
            cursor: Cursor.pointer,
          )
          .text(decoration: TextDecoration.none, fontSize: .9.rem)
          .flexbox(alignItems: AlignItems.center, gap: Gap(column: .4.rem)),
      css('&.link-button-filled', [
        css('&')
            .background(color: primaryMid)
            .text(color: Colors.white)
            .box(shadow: BoxShadow(offsetX: 1.px, offsetY: 1.px, blur: 3.px, color: Color.hex('#0003'))),
        css('&:hover')
            .background(color: primaryDark)
            .box(shadow: BoxShadow(offsetX: 1.px, offsetY: 1.px, blur: 5.px, color: Color.hex('#0004'))),
      ]),
      css('&.link-button-outlined', [
        css('&')
            .background(color: Colors.white)
            .box(opacity: 0.9, border: Border.all(BorderSide(color: Color.hex('#EEE'), width: 2.px)))
            .text(color: Colors.black),
        css('&:hover').background(color: Color.hex('#EEE')).box(opacity: 1),
      ]),
      css('&.link-button-icon', [
        css('&')
            .box(opacity: 0.9, padding: EdgeInsets.all(.7.rem))
            .background(color: Colors.transparent)
            .text(color: Colors.black),
        css('&:hover').box(opacity: 1).background(color: Colors.whiteSmoke),
      ]),
    ])
  ];
}
