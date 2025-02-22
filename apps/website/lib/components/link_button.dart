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
      css('&').styles(
        display: Display.block,
        radius: BorderRadius.circular(8.px),
        cursor: Cursor.pointer,
        transition: Transition('background', duration: 300),
        raw: {
          'user-select': 'none',
          '-webkit-user-select': 'none',
          '-webkit-tap-highlight-color': 'transparent',
        },
        textDecoration: TextDecoration.none,
        fontSize: .9.rem,
      ),
      css('.link-button-content').styles(
        padding: Padding.symmetric(horizontal: .9.rem, vertical: .7.rem),
        display: Display.flex,
        alignItems: AlignItems.center,
        justifyContent: JustifyContent.center,
        gap: Gap(column: .4.rem),
      ),
      css('&.link-button-filled', [
        css('&').styles(
          backgroundColor: primaryMid,
          color: Colors.white,
          position: Position.relative(),
          shadow: BoxShadow(offsetX: 1.px, offsetY: 1.px, blur: 3.px, color: shadowColor1),
        ),
        css('&:hover').styles(
          backgroundColor: primaryMidLow,
          shadow: BoxShadow(offsetX: 1.px, offsetY: 1.px, blur: 5.px, color: shadowColor2),
        ),
        css('&:after').styles(
          raw: {
            'content': '""',
            'filter': 'blur(5px)',
            '-webkit-filter': 'blur(5px)',
            'background': primaryGradient,
          },
          display: Display.block,
          position: Position.absolute(left: 1.rem, right: (-2).px, bottom: (-2).px),
          zIndex: ZIndex(-1),
          height: 40.px,
          opacity: 0,
          radius: BorderRadius.circular(100.px),
          transition: Transition('opacity', duration: 300),
          backgroundColor: primaryLight,
        ),
        css('&:hover:after').styles(opacity: 0.2),
      ]),
      css('&.link-button-outlined', [
        css('&').styles(
          opacity: 0.9,
          border: Border(width: 2.px, color: borderColor),
          color: textBlack,
        ),
        css('&:hover, &.active').styles(
          opacity: 1,
          backgroundColor: surface,
        ),
      ]),
      css('&.link-button-icon', [
        css('&').styles(
          opacity: 0.9,
          backgroundColor: Colors.transparent,
          color: textBlack,
        ),
        css('.link-button-content').styles(
          padding: Padding.all(.7.rem),
        ),
        css('&:hover').styles(
          opacity: 1,
          backgroundColor: hoverOverlayColor,
        ),
      ]),
    ])
  ];
}
