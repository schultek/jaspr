import 'dart:math';

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
        Component.element(
          key: ValueKey(particle.id),
          tag: 'g',
          styles: Styles(
            transform: Transform.combine([
              Transform.translate(x: particle.dx.percent, y: particle.dy.percent),
              Transform.rotate(particle.angle.deg),
            ]),
            raw: {'--particle-offset': '${particle.offset}px'},
          ),
          children: [
            circle(cx: "0", cy: "0", r: "${particle.size}", fill: primaryMid, []),
          ],
        ),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
        css('svg.particles', [
          css('&').styles(
            position: Position.absolute(top: Unit.zero, left: Unit.zero),
            width: 100.percent,
            height: 100.percent,
            overflow: Overflow.visible,
            pointerEvents: PointerEvents.none,
          ),
          css('circle').styles(
            raw: {'animation': 'particle 1s linear forwards'},
          ),
        ]),
        css.keyframes('particle', {
          '0%': Styles(
            transform: Transform.translate(y: 0.px),
          ),
          '90%': Styles(
            opacity: 1,
          ),
          '100%': Styles(
            opacity: 0,
            transform: Transform.translate(x: Unit.variable('--particle-offset')),
          ),
        })
      ];
}
