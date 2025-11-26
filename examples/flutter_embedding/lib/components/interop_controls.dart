import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../providers/app_state_provider.dart';

class InteropControls extends StatefulComponent {
  const InteropControls({super.key});

  @override
  State<InteropControls> createState() => _InteropControlsState();
}

class _InteropControlsState extends State<InteropControls> {
  @override
  Component build(BuildContext context) {
    var state = context.watch(appStateProvider);

    return fieldset(id: 'interop', [
      legend([.text('JS Interop')]),
      label(htmlFor: 'screen-selector', [
        .text('Screen'),
        select(
          name: 'screen-select',
          id: 'screen-selector',
          classes: 'screen',
          onChange: (value) {
            context.read(appStateProvider.notifier).changeDemoScreenTo(DemoScreen.values.byName(value.first));
          },
          [
            option(value: 'counter', [.text('Counter')]),
            option(value: 'textField', [.text('TextField')]),
            option(value: 'custom', [.text('Custom App')]),
          ],
        ),
      ]),
      label(htmlFor: 'value', classes: state.currentScreen != .counter ? 'disabled' : null, [
        .text('Value'),
        input(id: 'value', value: state.count.toString(), type: .text, attributes: {'readonly': ''}),
      ]),
      input(
        id: 'increment',
        value: 'Increment',
        type: .button,
        classes: state.currentScreen != .counter ? 'disabled' : null,
        events: events(
          onClick: () {
            context.read(appStateProvider.notifier).increment();
          },
        ),
      ),
    ]);
  }
}
