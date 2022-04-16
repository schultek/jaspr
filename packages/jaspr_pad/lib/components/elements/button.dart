import 'package:jaspr/jaspr.dart';

import '../../adapters/mdc.dart';

class Button extends StatelessComponent {
  const Button(
      {required this.id,
      required this.label,
      required this.icon,
      required this.onPressed,
      this.raised = false,
      this.dense = false,
      Key? key})
      : super(key: key);

  final String id;
  final String label;
  final String icon;
  final bool raised;
  final bool dense;
  final VoidCallback onPressed;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'button',
      classes: ['mdc-button', if (raised) 'mdc-button--raised', if (dense) 'mdc-button--dense'],
      id: id,
      attributes: {'type': 'button'},
      events: {'click': onPressed},
      children: [
        DomComponent(
          tag: 'i',
          classes: ['material-icons mdc-button__icon'],
          child: Text(icon),
        ),
        Text(label),
      ],
    );
  }

  @override
  Element createElement() => ButtonElement(this);
}

class ButtonElement extends StatelessElement {
  ButtonElement(Button component) : super(component);

  MDCRipple? _ripple;

  @override
  void render(DomBuilder b) {
    super.render(b);
    if (kIsWeb) {
      _ripple?.destroy();
      _ripple = MDCRipple((children.first as DomElement).source);
    }
  }
}
