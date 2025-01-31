import 'package:jaspr/jaspr.dart';
import 'package:website/components/gradient_border.dart';
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
    var child = span(classes: 'link-button-content', [
      if (label != null) text(label!),
      if (icon != null) Icon(icon!),
    ]);

    if (style == 'outlined') {
      child = GradientBorder(child: child, radius: 7);
    }
    yield a(classes: 'link-button link-button-$style', href: to, [
      child,
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('.link-button', [
      css('&')
          .box(
            display: Display.block,
            radius: BorderRadius.circular(8.px),
            cursor: Cursor.pointer,
            transition: Transition('background', duration: 300),
          )
          .text(decoration: TextDecoration.none, fontSize: .9.rem),
      css('.link-button-content')
          .box(padding: EdgeInsets.symmetric(horizontal: .9.rem, vertical: .7.rem))
          .flexbox(alignItems: AlignItems.center, gap: Gap(column: .4.rem)),
      css('&.link-button-filled', [
        css('&').background(color: primaryMid).text(color: Colors.white).box(
            position: Position.relative(),
            shadow: BoxShadow(offsetX: 1.px, offsetY: 1.px, blur: 3.px, color: shadowColor1)),
        css('&:hover').background(color: primaryMidLow).box(
              shadow: BoxShadow(offsetX: 1.px, offsetY: 1.px, blur: 5.px, color: shadowColor2),
            ),
        css('&:before')
            .raw({'content': '""', 'filter': 'blur(5px)'})
            .box(
              display: Display.block,
              position: Position.absolute(left: (-10).px, top: (-4).px, zIndex: ZIndex(-1)),
              width: 80.px,
              height: 40.px,
              opacity: 0,
              radius: BorderRadius.circular(100.px),
              transition: Transition('opacity', duration: 300),
            )
            .background(color: primaryDark),
        css('&:hover:before').box(opacity: 0.2),
        css('&:after')
            .raw({'content': '""', 'filter': 'blur(5px)'})
            .box(
              display: Display.block,
              position: Position.absolute(right: (-6).px, bottom: (-10).px, zIndex: ZIndex(-1)),
              width: 80.px,
              height: 40.px,
              opacity: 0,
              radius: BorderRadius.circular(100.px),
              transition: Transition('opacity', duration: 300),
            )
            .background(color: primaryLight),
        css('&:hover:after').box(opacity: 0.2),
      ]),
      css('&.link-button-outlined', [
        css('&')
            .box(opacity: 0.9, border: Border.all(BorderSide(width: 2.px, color: borderColor)))
            .text(color: textBlack),
        css('&:hover').box(opacity: 1).background(color: surface),
      ]),
      css('&.link-button-icon', [
        css('&').box(opacity: 0.9).background(color: Colors.transparent).text(color: textBlack),
        css('.link-button-content').box(padding: EdgeInsets.all(.7.rem)),
        css('&:hover').box(opacity: 1).background(color: hoverOverlayColor),
      ]),
    ])
  ];
}
