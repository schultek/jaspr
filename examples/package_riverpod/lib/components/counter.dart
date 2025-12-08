import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../providers/count_provider.dart';
import 'button.dart';

class Counter extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return .fragment([
      Button(
        label: 'Click Me',
        onPressed: () {
          context.read(countProvider.notifier).state++;
        },
      ),
      span([.text('Counter: ${context.watch(countProvider)}')]),
    ]);
  }
}
