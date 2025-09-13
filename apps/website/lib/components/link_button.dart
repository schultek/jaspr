import 'package:jaspr/jaspr.dart';
import 'package:website/components/gradient_border.dart';
import 'package:website/constants/theme.dart';

import 'icon.dart';

class LinkButton extends StatelessComponent {
  const LinkButton._({
    this.label,
    required this.icon,
    required this.to,
    required this.style,
    this.target,
    this.ariaLabel,
  });

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
  Component build(BuildContext context) {
    var child = span(classes: 'link-button-content', [if (label != null) text(label!), if (icon != null) Icon(icon!)]);

    if (style == 'outlined') {
      child = GradientBorder(child: child, radius: 7);
    }
    return a(
      classes: 'link-button link-button-$style',
      href: to,
      target: target,
      attributes: {if (ariaLabel != null) 'aria-label': ariaLabel!},
      [child],
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.link-button', [
      css('&').styles(
        display: Display.block,
        radius: BorderRadius.circular(8.px),
        cursor: Cursor.pointer,
        transition: Transition('background', duration: 300),
        fontSize: .9.rem,
        textDecoration: TextDecoration.none,
        raw: {'user-select': 'none', '-webkit-user-select': 'none', '-webkit-tap-highlight-color': 'transparent'},
      ),
      css('.link-button-content').styles(
        display: Display.flex,
        padding: Padding.symmetric(horizontal: .9.rem, vertical: .7.rem),
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
        gap: Gap(column: .4.rem),
      ),
      css('&.link-button-filled', [
        css('&').styles(
          position: Position.relative(),
          shadow: BoxShadow(offsetX: 1.px, offsetY: 1.px, blur: 3.px, color: shadowColor1),
          color: Colors.white,
          backgroundColor: primaryMid,
        ),
        css('&:hover').styles(
          shadow: BoxShadow(offsetX: 1.px, offsetY: 1.px, blur: 5.px, color: shadowColor2),
          backgroundColor: primaryMidLow,
        ),
        css('&:after').styles(
          display: Display.block,
          position: Position.absolute(left: 1.rem, right: (-2).px, bottom: (-2).px),
          zIndex: ZIndex(-1),
          height: 40.px,
          radius: BorderRadius.circular(100.px),
          opacity: 0,
          transition: Transition('opacity', duration: 300),
          backgroundColor: primaryLight,
          raw: {'content': '""', 'filter': 'blur(5px)', '-webkit-filter': 'blur(5px)', 'background': primaryGradient},
        ),
        css('&:hover:after').styles(opacity: 0.2),
      ]),
      css('&.link-button-outlined', [
        css('&').styles(
          border: Border(width: 2.px, color: borderColor),
          opacity: 0.9,
          color: textBlack,
        ),
        css('&:hover, &.active').styles(opacity: 1, backgroundColor: surface),
      ]),
      css('&.link-button-icon', [
        css('&').styles(opacity: 0.9, color: textBlack, backgroundColor: Colors.transparent),
        css('.link-button-content').styles(padding: Padding.all(.7.rem)),
        css('&:hover').styles(opacity: 1, backgroundColor: hoverOverlayColor),
      ]),
    ]),
  ];
}
