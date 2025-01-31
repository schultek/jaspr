import 'dart:async';
import 'dart:math';

import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;
import 'package:website/components/link_button.dart';
import 'package:website/pages/home/0_hero/components/overlay.dart';
import 'package:website/constants/theme.dart';

@client
class MeetJasprButton extends StatefulComponent {
  const MeetJasprButton({super.key});

  @override
  State createState() => MeetJasprButtonState();
}

class MeetJasprButtonState extends State<MeetJasprButton> {
  final notifier = ProgressNotifier();

  var showOverlay = false;

  @override
  void initState() {
    super.initState();
    notifier.addListener(() {
      setState(() {});
      if (notifier.done) {
        changeJasprText();
      }
    });
  }

  void changeJasprText() {
    final walker = web.document.createTreeWalker(web.document.body!, 0x4);

    while (walker.nextNode() != null) {
      var node = walker.currentNode as web.Text;
      node.textContent = node.textContent?.replaceAll('Jaspr', 'Jasper').replaceAll('jaspr', 'jasper');
    }
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (notifier.done) {
      if (showOverlay) {
        yield LinkButton.outlined(label: 'Meet Jasper', icon: 'jasper', to: '#meet');
        yield Overlay(onClose: () {
          setState(() {
            showOverlay = false;
          });
        });
      } else {
        yield DomComponent.wrap(
          events: {
            'click': (event) {
              event.preventDefault();
              setState(() {
                showOverlay = true;
              });
            },
          },
          child: LinkButton.outlined(label: 'Meet Jasper', icon: 'jasper', to: '#meet'),
        );
      }

      return;
    }

    yield div(id: 'meet-jaspr-button', [
      DomComponent.wrap(
        events: {
          'mousemove': (event) {
            var e = event as web.MouseEvent;
            var movement = (e.movementX.abs() + e.movementY.abs()) / 10;
            notifier.add(movement);
          },
          'click': (event) {
            event.preventDefault();
            web.document.querySelector('#meet')?.scrollIntoView(web.ScrollOptions(behavior: 'smooth'));
          },
        },
        styles: notifier.progressAfterCliff > 0
            ? Styles.raw({
                'background':
                    'linear-gradient(to right, ${primaryFaded.value} ${notifier.progressAfterCliff - 1}%, ${surface.value} ${notifier.progressAfterCliff}%)'
              })
            : null,
        child: LinkButton.outlined(label: 'Meet Jaspr', icon: 'custom-jaspr', to: '#meet'),
      ),
      svg(classes: 'particles', [
        for (final particle in notifier.particles)
          DomComponent(
            key: ValueKey(particle.id),
            tag: 'g',
            styles: Styles.box(
              transform: Transform.combine([
                Transform.translate(x: particle.dx.percent, y: particle.dy.percent),
                Transform.rotate(((particle.dy / 100 - 0.5) * 120).deg),
              ]),
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
    ]),
    css.keyframes('particle', {
      '0%': Styles.box(transform: Transform.translate(y: 0.px)),
      '90%': Styles.box(opacity: 1),
      '100%': Styles.box(transform: Transform.translate(x: Unit.variable('--particle-offset')), opacity: 0),
    })
  ];
}

class ProgressNotifier extends ValueNotifier<double> {
  ProgressNotifier() : super(0);

  bool get done => value >= 100;

  int get progressAfterCliff => done ? 100 : max((value - 2) / 0.98, 0).round();

  Timer? timer;

  var particleCooldown = 0.0;
  final List<({String id, int dx, int dy, int offset, double size})> particles = [];

  final random = Random();

  String randomId() {
    return random.nextInt(0xFFFF).toRadixString(16);
  }

  void add(double v) {
    if (done) return;
    if (value >= 100) {
      value = 100;
      timer?.cancel();
      timer = null;
      return;
    }

    value += v * min(0.9, (1.4 - value / 100));

    if (progressAfterCliff > 0) {
      if (particleCooldown > 1) {
        particleCooldown = 0;
      }
      if (particleCooldown == 0) {
        var particle = (
          id: randomId(),
          dx: progressAfterCliff,
          dy: random.nextInt(100),
          offset: 10 + random.nextInt(40),
          size: 0.5 + random.nextInt(3) / 2,
        );
        particles.add(particle);

        Future.delayed(Duration(seconds: 1), () {
          particles.remove(particle);
          notifyListeners();
        });
      }
      particleCooldown += v;
    }

    timer ??= Timer.periodic(Duration(milliseconds: 50), (_) {
      if (done) return;
      value--;
      if (value <= 0) {
        value = 0;
        timer?.cancel();
        timer = null;
      }
    });
  }
}
