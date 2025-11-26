import 'dart:math';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../constants/theme.dart';

typedef Particle = ({String id, int dx, int dy, double angle, int offset, double size});

class Particles extends StatelessComponent {
  const Particles({required this.particles, super.key});

  final List<Particle> particles;

  static final random = Random();

  static String randomId() {
    return random.nextInt(0xFFFF).toRadixString(16);
  }

  static int randomInt(int min, int max) {
    return min + random.nextInt(max - min);
  }

  @override
  Component build(BuildContext context) {
    return svg(classes: 'particles', [
      for (final particle in particles)
        .element(
          key: ValueKey(particle.id),
          tag: 'g',
          styles: Styles(
            transform: .combine([
              .translate(x: particle.dx.percent, y: particle.dy.percent),
              .rotate(particle.angle.deg),
            ]),
            raw: {'--particle-offset': '${particle.offset}px'},
          ),
          children: [circle(cx: "0", cy: "0", r: "${particle.size}", fill: primaryMid, [])],
        ),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('svg.particles', [
      css('&').styles(
        position: .absolute(top: .zero, left: .zero),
        width: 100.percent,
        height: 100.percent,
        overflow: .visible,
        pointerEvents: .none,
      ),
      css('circle').styles(raw: {'animation': 'particle 1s linear forwards'}),
    ]),
    css.keyframes('particle', {
      '0%': Styles(transform: .translate(y: 0.px)),
      '90%': Styles(opacity: 1),
      '100%': Styles(opacity: 0, transform: .translate(x: .variable('--particle-offset'))),
    }),
  ];
}
