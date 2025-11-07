import 'package:jaspr/jaspr.dart';

@client
class MiniCounter extends StatefulComponent {
  const MiniCounter({super.key});

  @override
  State<StatefulComponent> createState() => MiniCounterState();
}

class MiniCounterState extends State<MiniCounter> {
  int count = 0;

  @override
  Component build(BuildContext context) {
    return span(classes: 'client', [
      button(
        
        onClick: () {
          setState(() {
            count++;
          });
        },
        [text("Count: $count")],
      ),
    ]);
  }
}
