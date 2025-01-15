import 'package:jaspr/jaspr.dart';

@client
class ModesAnimation extends StatefulComponent {
  const ModesAnimation({super.key});

  @override
  State createState() => ModesAnimationState();
}

class ModesAnimationState extends State<ModesAnimation> {

  final List<String> texts = [
    'Single Page Apps',
    'Server Rendered Sites',
    'Static Sites',
  ];

  int index = 0;
  int characters = 0;

  @override
  void initState() {
    super.initState();
    characters = texts[index].length;

    if (kIsWeb) {
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

  Future<void> animateOut() async {
    while (characters > 0) {
      setState(() {
        characters--;
      });
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> animateIn() async {
    while (characters < texts[index].length) {
      setState(() {
        characters++;
      });
      await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var text = texts[index];
    yield raw(text.substring(0, characters).replaceAll(' ', '&nbsp;'));
  }
}
