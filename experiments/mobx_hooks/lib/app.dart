import 'dart:math';

import 'package:jaspr/jaspr.dart';

import 'mobx_hooks/hooks.dart';
import 'mobx_hooks/mobx_hooks.dart';

class App extends StatelessComponent {
  const App({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    print('build App');
    final text = useObs(() => 'initial');
    final output = useObs(() => 0);
    final seconds = useObs(() => 5);
    final inputElement = useRef<dynamic>(() => null);

    final reset = useCallback((_) {
      text.value = 'initial';
      seconds.value = 5;
      if (inputElement.value != null) {
        inputElement.value.value = text.value;
      }
    }, const []);

    useAutorun(() {
      final random = Random(text.value.hashCode);
      final subs =
          Stream.periodic(Duration(seconds: seconds.value)).listen((event) {
        print('event seconds: ${seconds.value}, text: "${text.value}"');
        output.value = random.nextInt(9000) + 1000;
      });
      return subs.cancel;
    });

    yield DomComponent(
      tag: 'div',
      styles: {
        'display': 'flex',
        'flex-direction': 'column',
        'justify-content': 'center',
        'align-items': 'flex-end',
        'height': '100%',
        'width': '270px',
        'margin': 'auto',
      },
      children: [
        DomComponent(
          tag: 'div',
          children: [
            DomComponent(
              tag: 'label',
              styles: {'padding': '0 10px;'},
              attributes: {'for': 'seed'},
              child: Text('seed'),
            ),
            DomComponent(
              tag: 'input',
              id: 'seed',
              attributes: {'type': 'text', 'value': text.value},
              events: {
                'input': (event) {
                  inputElement.value = event.target;
                  text.value = inputElement.value.value;
                }
              },
            ),
          ],
        ),
        DomComponent(tag: 'span', styles: {'height': '10px;'}),
        SecondsInput(seconds: seconds),
        DomComponent(
          tag: 'button',
          styles: {'margin': '10px 0;'},
          events: {'click': reset},
          child: Text('reset'),
        ),
        OutputText(output: output),
      ],
    );
  }
}

class SecondsInput extends StatelessComponent {
  const SecondsInput({super.key, required this.seconds});

  final Obs<int> seconds;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    print('build SecondsInput');
    final inputElement = useRef<dynamic>(() => null);

    useAutorun(() {
      final newValue = seconds.value.toString();
      if (inputElement.value != null) {
        inputElement.value.value = newValue;
      }
      return null;
    });

    yield DomComponent(
      tag: 'div',
      children: [
        DomComponent(
          tag: 'label',
          styles: {'padding': '0 10px;'},
          attributes: {'for': 'seconds'},
          child: Text('seconds'),
        ),
        DomComponent(
          tag: 'input',
          id: 'seconds',
          attributes: {
            'type': 'number',
            'value': inputElement.value?.value ?? seconds.value.toString(),
          },
          events: {
            'input': (event) {
              inputElement.value = event.target;
              final value = int.tryParse(event.target.value);
              if (value != null && value > 0) {
                seconds.value = value;
              }
            }
          },
        ),
      ],
    );
  }
}

class OutputText extends StatelessComponent {
  const OutputText({super.key, required this.output});

  final Obs<int> output;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    print('build OutputText');
    yield DomComponent(
      tag: 'div',
      children: [
        DomComponent(
          tag: 'h1',
          styles: {'padding': '0 10px;', 'font-family': 'mono'},
          child: Text('output: ${output.value}'),
        ),
      ],
    );
  }
}
