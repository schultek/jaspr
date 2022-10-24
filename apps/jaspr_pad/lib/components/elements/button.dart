import 'package:jaspr/jaspr.dart';

import '../../adapters/mdc.dart';

enum IconAffinity { left, right }

class Button extends StatefulComponent {
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
  State<StatefulComponent> createState() => ButtonState();
}

class ButtonState extends State<Button> {
  MDCRipple? _ripple;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield FindChildNode(
      onNodeFound: (RenderElement node) {
        if (kIsWeb) {
          _ripple?.destroy();
          if (component.label != null) {
            _ripple = MDCRipple(node.nativeElement);
          }
        }
      },
      child: DomComponent(
        tag: 'button',
        classes: [
          if (component.label != null) 'mdc-button',
          if (component.label == null && component.icon != null) 'mdc-icon-button',
          if (component.label == null && component.icon != null) 'material-icons',
          if (component.raised) 'mdc-button--raised',
          if (component.dense) 'mdc-button--dense',
          if (component.dialog) 'mdc-dialog__button'
        ],
        id: component.id,
        attributes: {if (component.label != null) 'type': 'button', if (component.disabled) 'disabled': ''},
        events: {'click': (e) => component.onPressed()},
        children: [
          if (component.label != null && component.iconAffinity == IconAffinity.right)
            DomComponent(
              tag: 'span',
              classes: ['mdc-button__label'],
              child: Text(component.label!),
            ),
          if (component.label != null && component.icon != null)
            DomComponent(
              tag: 'i',
              classes: ['material-icons mdc-button__icon'],
              attributes: {if (component.hideIcon) 'aria-hidden': 'true'},
              child: Text(component.icon!),
            ),
          if (component.label == null && component.icon != null) Text(component.icon!),
          if (component.label != null && component.iconAffinity == IconAffinity.left) Text(component.label!),
        ],
      ),
    );
  }
}
