import 'package:jaspr/jaspr.dart';

import '../../adapters/mdc.dart';

enum IconAffinity { left, right }

class Button extends StatelessComponent {
  const Button(
      {this.id,
      this.label,
      this.icon,
      required this.onPressed,
      this.raised = false,
      this.dense = false,
      this.disabled = false,
      this.hideIcon = false,
      this.dialog = false,
      this.iconAffinity = IconAffinity.left,
      Key? key})
      : super(key: key);

  final String? id;
  final String? label;
  final String? icon;
  final bool raised;
  final bool dense;
  final bool disabled;
  final bool hideIcon;
  final bool dialog;
  final IconAffinity iconAffinity;
  final VoidCallback onPressed;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'button',
      classes: [
        if (label != null) 'mdc-button',
        if (label == null && icon != null) 'mdc-icon-button',
        if (label == null && icon != null) 'material-icons',
        if (raised) 'mdc-button--raised',
        if (dense) 'mdc-button--dense',
        if (dialog) 'mdc-dialog__button'
      ],
      id: id,
      attributes: {if (label != null) 'type': 'button', if (disabled) 'disabled': ''},
      events: {'click': (e) => onPressed()},
      children: [
        if (label != null && iconAffinity == IconAffinity.right)
          DomComponent(
            tag: 'span',
            classes: ['mdc-button__label'],
            child: Text(label!),
          ),
        if (label != null && icon != null)
          DomComponent(
            tag: 'i',
            classes: ['material-icons mdc-button__icon'],
            attributes: {if (hideIcon) 'aria-hidden': 'true'},
            child: Text(icon!),
          ),
        if (label == null && icon != null) Text(icon!),
        if (label != null && iconAffinity == IconAffinity.left) Text(label!),
      ],
    );
  }

  @override
  Element createElement() => ButtonElement(this);
}

class ButtonElement extends StatelessElement {
  ButtonElement(Button component) : super(component);

  @override
  Button get component => super.component as Button;

  MDCRipple? _ripple;

  @override
  void render(DomBuilder b) {
    super.render(b);
    if (kIsWeb && component.label != null) {
      _ripple?.destroy();
      _ripple = MDCRipple((children.first as DomElement).source);
    }
  }
}
