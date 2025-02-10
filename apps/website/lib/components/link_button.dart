import 'package:jaspr/jaspr.dart';
import 'package:website/components/gradient_border.dart';
import 'package:website/constants/theme.dart';

import 'icon.dart';

class LinkButton extends StatelessComponent {
  const LinkButton._(
      {this.label, required this.icon, required this.to, required this.style, this.target, this.ariaLabel});

  final String? label;
  final String? icon;
  final String to;
  final String style;
  final Target? target;
  final String? ariaLabel;

  factory LinkButton.filled({required String label, String? icon, required String to}) {
    return LinkButton._(label: label, icon: icon, to: to, style: 'filled');
  }

  factory LinkButton.outlined({required String label, String? icon, required String to}) {
    return LinkButton._(label: label, icon: icon, to: to, style: 'outlined');
  }

  factory LinkButton.icon({required String icon, required String to, Target? target, String? ariaLabel}) {
    return LinkButton._(icon: icon, to: to, style: 'icon', target: target, ariaLabel: ariaLabel);
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
    yield a(classes: 'link-button link-button-$style', href: to, target: target, attributes: {
      if (ariaLabel != null) 'aria-label': ariaLabel!
    }, [
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
          .raw({
        'user-select': 'none',
        '-webkit-user-select': 'none',
        '-webkit-tap-highlight-color': 'transparent',
      }).text(decoration: TextDecoration.none, fontSize: .9.rem),
      css('.link-button-content')
          .box(padding: EdgeInsets.symmetric(horizontal: .9.rem, vertical: .7.rem))
          .flexbox(alignItems: AlignItems.center, justifyContent: JustifyContent.center, gap: Gap(column: .4.rem)),
      css('&.link-button-filled', [
        css('&').background(color: primaryMid).text(color: Colors.white).box(
            position: Position.relative(),
            shadow: BoxShadow(offsetX: 1.px, offsetY: 1.px, blur: 3.px, color: shadowColor1)),
        css('&:hover').background(color: primaryMidLow).box(
              shadow: BoxShadow(offsetX: 1.px, offsetY: 1.px, blur: 5.px, color: shadowColor2),
            ),
        css('&:after')
            .raw({
              'content': '""',
              'filter': 'blur(5px)',
              '-webkit-filter': 'blur(5px)',
              'background': primaryGradient,
            })
            .box(
              display: Display.block,
              position: Position.absolute(left: 1.rem, right: (-2).px, bottom: (-2).px, zIndex: ZIndex(-1)),
              //width: 80.px,
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
        css('&:hover, &.active').box(opacity: 1).background(color: surface),
      ]),
      css('&.link-button-icon', [
        css('&').box(opacity: 0.9).background(color: Colors.transparent).text(color: textBlack),
        css('.link-button-content').box(padding: EdgeInsets.all(.7.rem)),
        css('&:hover').box(opacity: 1).background(color: hoverOverlayColor),
      ]),
    ])
  ];
}
