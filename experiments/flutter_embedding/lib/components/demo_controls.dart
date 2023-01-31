import 'package:jaspr/html.dart';

import '../shared/app_state.dart'
  if (dart.library.io) '../shared/app_state_stub.dart';

class DemoControls extends StatefulComponent {
  const DemoControls({Key? key}) : super(key: key);

  @override
  State<DemoControls> createState() => _DemoControlsState();
}

class _DemoControlsState extends State<DemoControls> {
  AppStateNotifier? _state;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _state = AppStateNotifier();
      _state!.addListener(_setState);
    }
  }

  void _setState() {
    setState(() {});
  }

  @override
  void dispose() {
    _state?.removeListener(_setState);
    super.dispose();
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield h1([text('Element embedding')]);

    yield DomComponent(tag: 'fieldset', id: 'fx', children: [
      legend([text('Effects')]),
      input(value: 'Shadow', type: InputType.button, classes: ['fx'], attributes: {'data-fx': 'shadow'}, []),
      input(value: 'Mirror 🧪', type: InputType.button, classes: ['fx'], attributes: {'data-fx': 'mirror'}, []),
      input(value: 'Resize', type: InputType.button, classes: ['fx'], attributes: {'data-fx': 'resize'}, []),
      div(classes: [
        'tight'
      ], [
        input(value: 'Spin', type: InputType.button, classes: ['fx'], attributes: {'data-fx': 'spin'}, []),
        input(
            value: '0',
            type: InputType.range,
            id: 'rotation',
            classes: ['tight'],
            attributes: {'min': '-180', 'max': '180', 'list': 'markers'},
            []),
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
      input(value: 'Device', type: InputType.button, classes: ['fx'], attributes: {'data-fx': 'handheld'}, []),
    ]);

    yield DomComponent(tag: 'fieldset', id: 'interop', children: [
      legend([text('JS Interop')]),
      label(attributes: {
        'for': 'screen-selector'
      }, [
        text('Screen'),
        select(name: 'screen-select', id: 'screen-selector', classes: [
          'screens'
        ], events: {
          'change': (e) {
            _state!.changeDemoScreenTo(DemoScreen.values.byName(e.target.value));
          }
        }, [
          option(value: 'counter', [text('Counter')]),
          option(value: 'textField', [text('TextField')]),
          option(value: 'custom', [text('Custom App')]),
        ]),
      ]),
      label(attributes: {
        'for': 'value'
      }, classes: [
        if (_state?.currentScreen != DemoScreen.counter) 'disabled'
      ], [
        text('Value'),
        input(id: 'value', value: _state?.count.toString(), type: InputType.text, attributes: {'readonly': ''}, []),
      ]),
      input(id: 'increment', value: 'Increment', type: InputType.button, classes: [
        if (_state?.currentScreen != DemoScreen.counter) 'disabled'
      ], events: {
        'click': (_) {
          _state!.increment();
        }
      }, []),
    ]);
  }
}
