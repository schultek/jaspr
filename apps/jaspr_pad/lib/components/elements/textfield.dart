import 'package:jaspr/jaspr.dart';

import '../../adapters/html.dart' as html;
import '../../adapters/mdc.dart';
import '../utils/node_reader.dart';

class TextField extends StatefulComponent {
  const TextField({required this.label, this.placeholder, this.onChange, this.expand = false, super.key});

  final String label;
  final String? placeholder;
  final bool expand;
  final ValueChanged<String>? onChange;

  @override
  State createState() => TextFieldState();
}

class TextFieldState extends State<TextField> {
  MDCTextFieldOrStubbed? _textField;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomNodeReader(
      onNode: (node) {
        _textField ??= MDCTextField(node);
      },
      child: div(classes: 'mdc-text-field', styles: component.expand ? Styles.box(width: 100.percent) : null, [
        span(classes: 'mdc-floating-label', [
          text(component.label),
        ]),
        input(
          type: InputType.text,
          attributes: {if (component.placeholder != null) 'placeholder': component.placeholder!},
          events: {'input': (e) => component.onChange?.call((e.target as html.InputElementOrStubbed).value!)},
          classes: 'mdc-text-field__input',
          [],
        ),
      ]),
    );
  }
}
