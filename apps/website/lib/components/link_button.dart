import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../constants/theme.dart';
import 'gradient_border.dart';
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
    Component child = span(classes: 'link-button-content', [
      if (label != null) .text(label!),
      if (icon != null) Icon(icon!),
    ]);

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
        display: .block,
        radius: .circular(8.px),
        cursor: .pointer,
        transition: .new('background', duration: 300.ms),
        fontSize: .9.rem,
        textDecoration: .none,
        raw: {'user-select': 'none', '-webkit-user-select': 'none', '-webkit-tap-highlight-color': 'transparent'},
      ),
      css('.link-button-content').styles(
        display: .flex,
        padding: .symmetric(horizontal: .9.rem, vertical: .7.rem),
        justifyContent: .center,
        alignItems: .center,
        gap: .column(.4.rem),
      ),
      css('&.link-button-filled', [
        css('&').styles(
          position: .relative(),
          shadow: .new(offsetX: 1.px, offsetY: 1.px, blur: 3.px, color: shadowColor1),
          color: Colors.white,
          backgroundColor: primaryMid,
        ),
        css('&:hover').styles(
          shadow: .new(offsetX: 1.px, offsetY: 1.px, blur: 5.px, color: shadowColor2),
          backgroundColor: primaryMidLow,
        ),
        css('&:after').styles(
          display: .block,
          position: .absolute(left: 1.rem, right: (-2).px, bottom: (-2).px),
          zIndex: .new(-1),
          height: 40.px,
          radius: .circular(100.px),
          opacity: 0,
          transition: .new('opacity', duration: 300.ms),
          backgroundColor: primaryLight,
          raw: {'content': '""', 'filter': 'blur(5px)', '-webkit-filter': 'blur(5px)', 'background': primaryGradient},
        ),
        css('&:hover:after').styles(opacity: 0.2),
      ]),
      css('&.link-button-outlined', [
        css('&').styles(
          border: .all(width: 2.px, color: borderColor),
          opacity: 0.9,
          color: textBlack,
        ),
        css('&:hover, &.active').styles(opacity: 1, backgroundColor: surface),
      ]),
      css('&.link-button-icon', [
        css('&').styles(opacity: 0.9, color: textBlack, backgroundColor: Colors.transparent),
        css('.link-button-content').styles(padding: .all(.7.rem)),
        css('&:hover').styles(opacity: 1, backgroundColor: hoverOverlayColor),
      ]),
    ]),
  ];
}
