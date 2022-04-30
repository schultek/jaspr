import 'package:jaspr/jaspr.dart';

import '../../adapters/mdc.dart';

class TextField extends StatelessComponent {
  const TextField({required this.label, this.placeholder, this.onChange, this.expand = false, Key? key})
      : super(key: key);

  final String label;
  final String? placeholder;
  final bool expand;
  final ValueChanged<String>? onChange;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: ['mdc-text-field'],
      styles: expand ? {'width': '100%'} : null,
      children: [
        DomComponent(
          tag: 'span',
          classes: ['mdc-floating-label'],
          child: Text(label),
        ),
        DomComponent(
          tag: 'input',
          attributes: {'type': 'text', if (placeholder != null) 'placeholder': placeholder!},
          events: {'input': (e) => onChange?.call(e.target.value)},
          classes: ['mdc-text-field__input'],
        ),
      ],
    );
  }

  @override
  Element createElement() => TextFieldElement(this);
}

class TextFieldElement extends StatelessElement {
  TextFieldElement(TextField component) : super(component);

  MDCTextField? _textField;

  @override
  void render(DomBuilder b) {
    if (_textField == null) {
      super.render(b);
      if (kIsWeb) {
        _textField = MDCTextField((children.first as DomElement).source);
      }
    } else {
      b.skipNode();
    }
  }
}
