import 'package:jaspr/jaspr.dart';

import '../../adapters/html.dart';
import '../../adapters/mdc.dart';
import '../utils/node_reader.dart';

enum IconAffinity { left, right }

class Button extends StatefulComponent {
  const Button({
    this.id,
    this.label,
    this.icon,
    required this.onPressed,
    this.raised = false,
    this.dense = false,
    this.disabled = false,
    this.hideIcon = false,
    this.dialog = false,
    this.iconAffinity = IconAffinity.left,
    super.key,
  });

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
  State<StatefulComponent> createState() => ButtonState();
}

class ButtonState extends State<Button> {
  MDCRippleOrStubbed? _ripple;

  @override
  Component build(BuildContext context) {
    return DomNodeReader(
      onNode: (ElementOrStubbed node) {
        _ripple?.destroy();
        if (component.label != null) {
          _ripple = MDCRipple(node);
        }
      },
      child: button(
        classes: [
          if (component.label != null) 'mdc-button',
          if (component.label == null && component.icon != null) 'mdc-icon-button',
          if (component.label == null && component.icon != null) 'material-icons',
          if (component.raised) 'mdc-button--raised',
          if (component.dense) 'mdc-button--dense',
          if (component.dialog) 'mdc-dialog__button'
        ].join(' '),
        id: component.id,
        attributes: {if (component.label != null) 'type': 'button', if (component.disabled) 'disabled': ''},
        events: {'click': (e) => component.onPressed()},
        [
          if (component.label != null && component.iconAffinity == IconAffinity.right)
            span(classes: 'mdc-button__label', [
              text(component.label!),
            ]),
          if (component.label != null && component.icon != null)
            i(
              classes: 'material-icons mdc-button__icon',
              attributes: {if (component.hideIcon) 'aria-hidden': 'true'},
              [text(component.icon!)],
            ),
          if (component.label == null && component.icon != null) Text(component.icon!),
          if (component.label != null && component.iconAffinity == IconAffinity.left) Text(component.label!),
        ],
      ),
    );
  }
}
