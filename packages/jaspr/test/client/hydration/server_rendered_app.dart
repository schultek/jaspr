import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class HydrationShell extends StatelessComponent {
  const HydrationShell({required this.child});

  final Component child;

  @override
  Component build(BuildContext context) => div(id: 'shell', [child]);
}

class HydrationCounter extends StatefulComponent {
  const HydrationCounter({required this.id, required this.seed, super.key});

  final int id;
  final int seed;

  @override
  State<HydrationCounter> createState() => HydrationCounterState();
}

class HydrationCounterState extends State<HydrationCounter> with SyncStateMixin<HydrationCounter, int> {
  int _count = 0;
  int _clicks = 0;

  @override
  void initState() {
    // Hydration must restore server state instead of reproducing it from parameters.
    _count = kIsWeb ? -1 : component.seed + component.id;
    super.initState();
  }

  @override
  int getState() => _count;

  @override
  void updateState(int value) => _count = value;

  @override
  Component build(BuildContext context) => button(
    id: 'counter-${component.id}',
    onClick: () => setState(() => _clicks++),
    [.text('${component.id}:$_count:$_clicks')],
  );
}
