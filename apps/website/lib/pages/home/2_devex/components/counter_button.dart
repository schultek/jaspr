import 'dart:math';

import 'package:jaspr/jaspr.dart';

import '../../../../components/link_button.dart';
import '../../../../components/particles.dart';

@client
class CounterButton extends StatefulComponent {
  const CounterButton({super.key});

  @override
  State createState() => CounterButtonState();
}

class CounterButtonState extends State<CounterButton> {
  int count = 0;
  List<Particle> particles = [];

  Future<void> increment() async {
    setState(() {
      count++;
    });

    for (var i = 0; i < 20; i++) {
      final dx = Particles.randomInt(0, 100);
      final dy = Particles.randomInt(0, 100);
      var particle = (
        id: Particles.randomId(),
        dx: dx,
        dy: dy,
        angle: atan2(dy - 50, dx - 50) * (180 / pi),
        offset: Particles.randomInt(10, 40),
        size: Particles.randomInt(1, 4) / 2,
      );
      setState(() {
        particles.add(particle);
      });

      Future.delayed(Duration(seconds: 1), () {
        particles.remove(particle);
        setState(() {});
      });

      await Future.delayed(Duration(milliseconds: 20));
    }
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'counter-container', [
      Particles(particles: particles),
      DomComponent.wrap(
        events: {
          'click': (event) {
            event.preventDefault();
            increment();
          }
        },
        styles: Styles.box(width: 10.em).text(align: TextAlign.center, whiteSpace: WhiteSpace.noWrap),
        child: LinkButton.filled(label: 'Clicked $count times', to: ''),
      ),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('.counter-container').box(position: Position.relative()),
  ];
}
