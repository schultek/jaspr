import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../providers/effects_provider.dart';

class EffectsControls extends StatelessComponent {
  const EffectsControls({
    Key? key,
  }) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var effects = context.watch(effectsProvider);

    Component effectButton(String label, String fx, [bool alignTop = false]) {
      return input(
        value: label,
        type: InputType.button,
        classes: ['fx', if (alignTop) 'align-top', if (fx != 'handheld' && effects.contains('handheld')) 'disabled'],
        attributes: {'data-fx': fx},
        [],
      );
    }

    yield fieldset(id: 'fx', events: {
      'click': (event) {
        var fx = (event.target as dynamic).dataset['fx'];
        if (fx != null) {
          context.read(effectsProvider.notifier).update((e) {
            return e.contains(fx) ? ({...e}..remove(fx)) : {...e, fx};
          });
        }
      },
      'input': (event) {
        if ((event.target as dynamic).id == 'rotation') {
          context.read(effectsProvider.notifier).update((e) => {...e}..remove('spin'));
          context.read(rotationProvider.notifier).state = double.parse((event.target as dynamic).value);
        }
      },
    }, [
      legend([text('Effects')]),
      effectButton('Shadow', 'shadow'),
      effectButton('Mirror 🧪', 'mirror'),
      effectButton('Resize', 'resize', true),
      div(classes: [
        'tight'
      ], [
        effectButton('Spin', 'spin'),
        input(
          value: context.watch(rotationProvider).toString(),
          type: InputType.range,
          id: 'rotation',
          classes: ['tight', if (effects.contains('handheld')) 'disabled'],
          attributes: {'min': '-180', 'max': '180', 'list': 'markers'},
          [],
        ),
        datalist(id: 'markers', [
          option(value: '-180', []),
          option(value: '-135', []),
          option(value: '-45', []),
          option(value: '0', []),
          option(value: '45', []),
          option(value: '135', []),
          option(value: '180', []),
        ]),
      ]),
      effectButton('Device', 'handheld'),
    ]);
  }
}
