import 'package:jaspr/jaspr.dart';

import '../../adapters/mdc.dart';

class TextField extends StatefulComponent {
  const TextField({required this.label, this.placeholder, this.onChange, this.expand = false, Key? key})
      : super(key: key);

  final String label;
  final String? placeholder;
  final bool expand;
  final ValueChanged<String>? onChange;

  @override
  State createState() => TextFieldState();
}

class TextFieldState extends State<TextField> {
  MDCTextField? _textField;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield FindChildNode(
      onNodeFound: (node) {
        if (kIsWeb && _textField == null) {
          _textField = MDCTextField(node.nativeElement);
        }
      },
      child: DomComponent(
        tag: 'div',
        classes: ['mdc-text-field'],
        styles: component.expand ? {'width': '100%'} : null,
        children: [
          DomComponent(
            tag: 'span',
            classes: ['mdc-floating-label'],
            child: Text(component.label),
          ),
          DomComponent(
            tag: 'input',
            attributes: {'type': 'text', if (component.placeholder != null) 'placeholder': component.placeholder!},
            events: {'input': (e) => component.onChange?.call(e.target.value)},
            classes: ['mdc-text-field__input'],
          ),
        ],
      ),
    );
  }
}
