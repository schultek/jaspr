import 'dart:async';
import 'dart:math';

import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart';
import 'package:website/components/link_button.dart';
import 'package:website/constants/theme.dart';

@client
class MeetJasprButton extends StatefulComponent {
  const MeetJasprButton({super.key});

  @override
  State createState() => MeetJasprButtonState();
}

class MeetJasprButtonState extends State<MeetJasprButton> {
  double activation = 0;

  bool get activated => activation >= 100;
  int get progress => activated ? 100 : max((activation - 10) / 0.9, 0).round();

  Timer? timer;

  var particleCooldown = 0;

  final List<({String id, int dx, int dy, int offset, int size})> particles = [];

  final random = Random();

  String randomId() {
    return random.nextInt(0xFFFF).toRadixString(16);
  }

  void onActivate(double movement) {
    if (activated) return;
    if (activation >= 100) {
      setState(() {
        activation = 100;
      });
      timer?.cancel();
      timer = null;
      return;
    }

    setState(() {
      activation += movement;
    });

    if (progress > 0) {
      if (particleCooldown > 5) {
        particleCooldown = 0;
      }
      if (particleCooldown == 0) {
        var particle = (
          id: randomId(),
          dx: progress,
          dy: random.nextInt(100),
          offset: 10 + random.nextInt(40),
          size: 1 + random.nextInt(2),
        );
        particles.add(particle);

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            particles.remove(particle);
          });
        });
      }
      particleCooldown++;
    }

    timer ??= Timer.periodic(Duration(milliseconds: 50), (_) {
      if (activated) return;
      setState(() {
        activation--;
      });
      if (activation <= 0) {
        activation = 0;
        timer?.cancel();
        timer = null;
      }
    });
  }

  var jasperImageIndex = 1;

  void addJasper() {
    if (jasperImageIndex >= 4) return;
    setState(() {
      jasperImageIndex++;
    });
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (activated) {
      yield DomComponent.wrap(
        events: {
          'click': (event) {
            event.preventDefault();
            addJasper();
          },
        },
        styles: Styles.box(position: Position.relative(zIndex: ZIndex(100))),
        child: LinkButton.outlined(label: 'Meet Jasper', icon: 'jasper', to: '#meet'),
      );

      for (var i = 1; i < jasperImageIndex; i++) {
        yield img(classes: "jasper-image", src: 'images/jasper/0$i.jpg', alt: 'Jasper');
      }

      return;
    }

    yield div(id: 'meet-jaspr-button', [
      DomComponent.wrap(
        events: {
          'mousemove': (event) {
            var e = event as MouseEvent;
            var movement = (e.movementX.abs() + e.movementY.abs()) / 10;
            onActivate(movement);
          },
          'click': (event) {
            event.preventDefault();
            document.querySelector('#meet')?.scrollIntoView(ScrollOptions(behavior: 'smooth'));
          },
        },
        styles: progress > 0
            ? Styles.raw({
                'background': 'linear-gradient(to right, ${primaryMid.value}44 ${progress - 1}%, whitesmoke $progress%)'
              })
            : null,
        child: LinkButton.outlined(label: 'Meet Jaspr', icon: 'jaspr', to: '#meet'),
      ),
      svg([
        for (final particle in particles)
          DomComponent(
            key: ValueKey(particle.id),
            tag: 'g',
            styles: Styles.box(
              transform: Transform.combine([
                Transform.translate(x: particle.dx.percent, y: particle.dy.percent),
                Transform.rotate(((particle.dy / 100 - 0.5) * 120).deg),
              ]),
              // opacity: (4-particle.size) / 3,
            ).raw({'--particle-offset': '${particle.offset}px'}),
            children: [
              circle(cx: "0", cy: "0", r: "${particle.size}", fill: primaryMid, []),
            ],
          ),
      ]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('#meet-jaspr-button', [
      css('&').box(position: Position.relative()),
      css('svg', [
        css('&')
            .box(
                overflow: Overflow.visible,
                position: Position.absolute(top: Unit.zero, left: Unit.zero),
                width: 100.percent,
                height: 100.percent)
            .raw({'pointer-events': 'none'}),
        css('circle').raw({'animation': 'particle 1s linear forwards'}),
      ]),
    ]),
    css('.jasper-image', [
      css('&')
          .box(
        position: Position.absolute(top: 10.percent, left: 10.percent),
        width: 80.percent,
        height: 80.percent,
        
      ).raw({'object-fit': 'contain'}),
    ]),
    css.keyframes('particle', {
      '0%': Styles.box(transform: Transform.translate(y: 0.px)),
      '90%': Styles.box(opacity: 1),
      '100%': Styles.box(transform: Transform.translate(x: Unit.variable('--particle-offset')), opacity: 0),
    })
  ];
}
