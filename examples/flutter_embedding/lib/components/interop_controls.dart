import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../providers/app_state_provider.dart';

class InteropControls extends StatefulComponent {
  const InteropControls({Key? key}) : super(key: key);

  @override
  State<InteropControls> createState() => _InteropControlsState();
}

class _InteropControlsState extends State<InteropControls> {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    var state = context.watch(appStateProvider);

    yield fieldset(id: 'interop', [
      legend([text('JS Interop')]),
      label(htmlFor: 'screen-selector', [
        text('Screen'),
        select(name: 'screen-select', id: 'screen-selector', classes: [
          'screen'
        ], events: {
          'change': (e) {
            context.read(appStateProvider.notifier).changeDemoScreenTo(DemoScreen.values.byName(e.target.value));
          }
        }, [
          option(value: 'counter', [text('Counter')]),
          option(value: 'textField', [text('TextField')]),
          option(value: 'custom', [text('Custom App')]),
        ]),
      ]),
      label(htmlFor: 'value', classes: [
        if (state.currentScreen != DemoScreen.counter) 'disabled'
      ], [
        text('Value'),
        input(id: 'value', value: state.count.toString(), type: InputType.text, attributes: {'readonly': ''}, []),
      ]),
      input(id: 'increment', value: 'Increment', type: InputType.button, classes: [
        if (state.currentScreen != DemoScreen.counter) 'disabled'
      ], events: {
        'click': (_) {
          context.read(appStateProvider.notifier).increment();
        }
      }, []),
    ]);
  }
}
