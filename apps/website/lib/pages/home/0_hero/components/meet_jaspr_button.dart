import 'dart:async';
import 'dart:math';

import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;
import 'package:website/components/link_button.dart';
import 'package:website/components/particles.dart';
import 'package:website/constants/theme.dart';
import 'package:website/pages/home/0_hero/components/overlay.dart';
import 'package:website/utils/events.dart';

@client
class MeetJasprButton extends StatefulComponent {
  const MeetJasprButton({super.key});

  @override
  State createState() => MeetJasprButtonState();
}

class MeetJasprButtonState extends State<MeetJasprButton> {
  final notifier = ProgressNotifier();
  Timer? touchTimer;

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

  void scrollToMeet() {
    var el = web.document.querySelector('#meet') as web.HTMLElement;
    web.window.scrollTo(web.ScrollToOptions(top: el.offsetTop, behavior: 'smooth'));
  }

  @override
  Component build(BuildContext context) {
    final children = <Component>[];
    if (notifier.done) {
      if (showOverlay) {
        children.add(LinkButton.outlined(label: 'Meet Jasper', icon: 'jasper', to: '#meet'));
        children.add(Overlay(onClose: () {
          setState(() {
            showOverlay = false;
          });
        }));
      } else {
        children.add(Component.wrapElement(
          events: {
            'click': (event) {
              event.preventDefault();
              setState(() {
                showOverlay = true;
              });
            },
          },
          child: LinkButton.outlined(label: 'Meet Jasper', icon: 'jasper', to: '#meet'),
        ));
      }

      return fragment(children);
    }

    children.add(div(id: 'meet-jaspr-button', [
      Component.wrapElement(
        classes: touchTimer != null ? 'active' : null,
        events: {
          'mousemove': (event) {
            var e = event as web.MouseEvent;
            var movement = (e.movementX.abs() + e.movementY.abs()) / 10;
            notifier.add(movement);
          },
          'touchstart': (event) {
            event.preventDefault();
            touchTimer = Timer(Duration(seconds: 1), () {
              touchTimer = Timer.periodic(Duration(milliseconds: 50), (_) {
                notifier.add(2, linear: true);
              });
            });
            setState(() {});
          },
          'touchend': (event) {
            touchTimer?.cancel();
            setState(() {
              touchTimer = null;
            });
            if (notifier.progressAfterCliff == 0) {
              scrollToMeet();
            }
          },
          'click': (event) {
            event.preventDefault();
            scrollToMeet();
          },
        },
        styles: notifier.progressAfterCliff > 0
            ? Styles(raw: {
                'background':
                    'linear-gradient(to right, ${primaryFaded.value} ${notifier.progressAfterCliff - 1}%, ${surface.value} ${notifier.progressAfterCliff}%)'
              })
            : null,
        child: LinkButton.outlined(label: 'Meet Jaspr', icon: 'custom-jaspr', to: '#meet'),
      ),
      Particles(particles: notifier.particles),
    ]));
    return fragment(children);
  }

  @css
  static List<StyleRule> get styles => [
        css('#meet-jaspr-button', [
          css('&').styles(position: Position.relative()),
        ]),
      ];
}

class ProgressNotifier extends ValueNotifier<double> {
  ProgressNotifier() : super(0);

  final isSafari = kIsWeb &&
      RegExp(r'^((?!chrome|android).)*safari', caseSensitive: false) //
          .hasMatch(web.window.navigator.userAgent);
  late final scaleFactor = isSafari ? 2 : 1;

  bool get done => value >= 100;

  int get progressAfterCliff => done ? 100 : max((value - 2) / 0.98, 0).round();

  Timer? timer;

  var particleCooldown = 0.0;
  final List<Particle> particles = [];

  void add(double v, {bool linear = false}) {
    if (done) return;

    if (value >= 100) {
      value = 100;
      timer?.cancel();
      timer = null;
      return;
    }

    if (linear) {
      value += v;
    } else {
      value += v * min(1, (1.7 - value / 100)) * scaleFactor;
    }

    if (done) {
      captureEasterEgg();
    }

    if (progressAfterCliff > 0) {
      if (particleCooldown > 2) {
        particleCooldown = 0;
      }
      if (particleCooldown == 0) {
        var dy = Particles.randomInt(0, 100);
        var particle = (
          id: Particles.randomId(),
          dx: progressAfterCliff,
          dy: dy,
          angle: (dy / 100 - 0.5) * 120,
          offset: Particles.randomInt(10, 50),
          size: Particles.randomInt(1, 4) / 2,
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
