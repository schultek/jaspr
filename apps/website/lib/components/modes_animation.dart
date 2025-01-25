import 'dart:math';

import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart';

@client
class ModesAnimation extends StatefulComponent {
  const ModesAnimation({super.key});

  @override
  State createState() => ModesAnimationState();
}

class ModesAnimationState extends State<ModesAnimation> {

  final List<(String, String)> texts = [
    ('Static Sites', 'static'),
    ('Server Rendered Sites', 'server'),
    ('Single Page Apps', 'client'),
  ];

  int index = 0;
  int characters = 0;

  late HTMLElement modeSpan;

  @override
  void initState() {
    super.initState();
    characters = texts[index].$1.length;

    if (kIsWeb) {
      modeSpan = document.querySelector('.jaspr-mode .hljs-string') as HTMLElement;
      runAnimation();
    }
  }

  Future<void> runAnimation() async {
    while (true) {
      await animateOut();
      index = (index + 1) % texts.length;
      await Future.delayed(const Duration(milliseconds: 300));
      await animateIn();
      await Future.delayed(const Duration(milliseconds: 3000));
    }
  }

  void setMode() {
    final l = min(texts[index].$2.length, characters);
    modeSpan.textContent = texts[index].$2.substring(0, l);
  }

  Future<void> animateOut() async {
    while (characters > 0) {
      setState(() {
        characters--;
      });
      setMode();
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> animateIn() async {
    while (characters < texts[index].$1.length) {
      setState(() {
        characters++;
      });
      setMode();
      await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var text = texts[index].$1;
    yield raw(text.substring(0, characters).replaceAll(' ', '&nbsp;'));
  }
}
