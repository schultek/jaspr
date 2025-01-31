import 'package:jaspr/jaspr.dart';

import '../constants/theme.dart';

class GradientBorder extends StatelessComponent {
  const GradientBorder({required this.child, this.radius = 4, super.key});

  final Component child;
  final int radius;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'gradient-border-container', [
      div(classes: 'gradient-border', [
        svg(width: 100.percent, height: 100.percent, [
          DomComponent(tag: 'defs', children: [
            DomComponent(tag: 'linearGradient', attributes: {
              'id': 'linear',
              'x1': '0%',
              'y1': '0%',
              'x2': '100%',
              'y2': '100%'
            }, children: [
              DomComponent(tag: 'stop', attributes: {'offset': '0%', 'stop-color': primaryDark.value}),
              DomComponent(tag: 'stop', attributes: {'offset': '50%', 'stop-color': primaryMid.value}),
              DomComponent(tag: 'stop', attributes: {'offset': '100%', 'stop-color': primaryLight.value}),
            ]),
          ]),
          rect(x: "0", y: "0", width: "100%", height: "100%", attributes: {
            'pathLength': '100',
            'rx': '$radius',
            'ry': '$radius',
            'fill': 'none',
            'stroke': 'url(#linear)',
            'stroke-width': '2',
          }, []),
        ]),
      ]),
      child,
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('.gradient-border-container', [
      css('&').box(
        height: 100.percent,
        position: Position.relative(),
      ),
      css('.gradient-border', [
        css('&').box(
          position: Position.absolute(top: (-1).px, left: (-1).px, right: (-1).px, bottom: (-1).px),
        ),
        css('svg').box(overflow: Overflow.visible),
      ]),
      css('rect').raw({'stroke-dasharray': '0 101'}).box(
        transition: Transition('stroke-dasharray', duration: 300, curve: Curve.easeOut),
      ),
      css('&:hover rect').raw({'stroke-dasharray': '50 0 52'}),
    ]),
  ];
}
