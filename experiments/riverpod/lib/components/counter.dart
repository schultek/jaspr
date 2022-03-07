import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'button.dart';

final counterProvider = StateProvider<int>((ref) {
  ref.onPreload(() async {
    await Future.delayed(Duration(seconds: 1));
    ref.controller.state = 200;
  });

  var state = ref.onSync<int>(
    id: 'counter',
    onUpdate: (v) {
      ref.controller.update((state) => v ?? state);
    },
    onSave: () {
      return ref.controller.state;
    },
  );

  return state ?? 0;
});

class Counter extends StatelessComponent with PreloadProviderDependencies {
  @override
  Iterable<ProviderBase> get dependencies => [counterProvider];

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Button(
      label: 'Click Me',
      onPressed: () {
        context.read(counterProvider.state).state++;
      },
    );

    yield DomComponent(
      tag: 'span',
      child: Text('Counter: ${context.watch(counterProvider)}'),
    );
  }
}
