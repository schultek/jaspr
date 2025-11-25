import 'package:jaspr/dom.dart';

import '../constants/theme.dart';

class GradientBorder extends StatelessComponent {
  const GradientBorder({required this.child, this.radius = 4, this.fixed = false, super.key});

  final Component child;
  final int radius;
  final bool fixed;

  @override
  Component build(BuildContext context) {
    return div(classes: 'gradient-border-container${fixed ? ' fixed' : ''}', [
      div(classes: 'gradient-border', [
        svg(width: 100.percent, height: 100.percent, [
          .element(
            tag: 'defs',
            children: [
              .element(
                tag: 'linearGradient',
                attributes: {'id': 'linear', 'x1': '0%', 'y1': '0%', 'x2': '100%', 'y2': '100%'},
                children: [
                  .element(tag: 'stop', attributes: {'offset': '0%', 'stop-color': primaryDark.value}),
                  .element(tag: 'stop', attributes: {'offset': '50%', 'stop-color': primaryMid.value}),
                  .element(tag: 'stop', attributes: {'offset': '100%', 'stop-color': primaryLight.value}),
                ],
              ),
            ],
          ),
          rect(
            x: "0",
            y: "0",
            width: "100%",
            height: "100%",
            attributes: {
              'pathLength': '100',
              'rx': '$radius',
              'ry': '$radius',
              'fill': 'none',
              'stroke': 'url(#linear)',
              'stroke-width': '2',
            },
            [],
          ),
        ]),
      ]),
      child,
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.gradient-border-container', [
      css('&').styles(position: .relative(), height: 100.percent),
      css('.gradient-border', [
        css('&').styles(
          position: .absolute(top: (-1).px, left: (-1).px, right: (-1).px, bottom: (-1).px),
        ),
        css('svg').styles(overflow: .visible),
      ]),
      css('rect').styles(
        transition: .new('stroke-dasharray', duration: 300.ms, curve: .easeOut),
        raw: {'stroke-dasharray': '0 101'},
      ),
      css('&:hover rect, &.fixed rect').styles(raw: {'stroke-dasharray': '50 0 52'}),
    ]),
    css('.active .gradient-border rect').styles(raw: {'stroke-dasharray': '50 0 52'}),
  ];
}
