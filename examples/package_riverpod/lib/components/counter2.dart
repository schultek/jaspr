import 'dart:math';

import 'package:jaspr/jaspr.dart';

import 'counter2.sync.dart';

class Counter2 extends StatefulComponent {
  const Counter2({super.key});

  @override
  State<Counter2> createState() => _Counter2State();
}

class _Counter2State extends State<Counter2> with Counter2StateSyncMixin {
  @sync
  int count = 0;

  @sync
  Color? color;

  void initState() {
    super.initState();
    if (!kIsWeb) {
      var rnd = Random();
      count = rnd.nextInt(100);
      color = Colors.blue;
    }
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield span(styles: Styles.text(color: count > 50 ? color : null), [text('Counter: $count')]);
    yield button(onClick: () => setState(() => count++), [text('Click')]);
  }
}
