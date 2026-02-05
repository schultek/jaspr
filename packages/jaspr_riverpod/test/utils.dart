import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

Component providerApp(ComponentBuilder builder) {
  return ProviderScope(child: Builder(builder: builder));
}

class Button extends StatelessComponent {
  const Button({required this.label, required this.onPressed, super.key});

  final String label;
  final void Function() onPressed;

  @override
  Component build(BuildContext context) {
    return button(events: {'click': (e) => onPressed()}, [Component.text(label)]);
  }
}

class DoublingCodec with Codec<int, int> {
  const DoublingCodec();

  @override
  Converter<int, int> get decoder => CallbackConverter((v) => v ~/ 2);

  @override
  Converter<int, int> get encoder => CallbackConverter((v) => v * 2);
}

class CallbackConverter extends Converter<int, int> {
  const CallbackConverter(this._convert);

  final int Function(int) _convert;

  @override
  int convert(int input) => _convert(input);
}
