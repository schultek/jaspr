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
  Iterable<Component> build(BuildContext context) sync* {
    yield svg(classes: 'particles', [
      for (final particle in particles)
        DomComponent(
          key: ValueKey(particle.id),
          tag: 'g',
          styles: Styles.box(
            transform: Transform.combine([
              Transform.translate(x: particle.dx.percent, y: particle.dy.percent),
              Transform.rotate(particle.angle.deg),
            ]),
          ).raw({'--particle-offset': '${particle.offset}px'}),
          children: [
            circle(cx: "0", cy: "0", r: "${particle.size}", fill: primaryMid, []),
          ],
        ),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('svg.particles', [
      css('&')
          .box(
              overflow: Overflow.visible,
              position: Position.absolute(top: Unit.zero, left: Unit.zero),
              width: 100.percent,
              height: 100.percent)
          .raw({'pointer-events': 'none'}),
      css('circle').raw({'animation': 'particle 1s linear forwards'}),
    ]),
    css.keyframes('particle', {
      '0%': Styles.box(transform: Transform.translate(y: 0.px)),
      '90%': Styles.box(opacity: 1),
      '100%': Styles.box(transform: Transform.translate(x: Unit.variable('--particle-offset')), opacity: 0),
    })
  ];
}
