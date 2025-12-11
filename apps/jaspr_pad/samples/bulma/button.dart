import 'package:jaspr/dom.dart' hide Color;
import 'package:jaspr/jaspr.dart';

import 'colors.dart';

/// Bulma Button Component
/// Supports a limited subset of the available options
/// See https://bulma.io/documentation/elements/button/ for a detailed description
class Button extends StatelessComponent {
  const Button({
    required this.child,
    required this.onPressed,
    this.color,
    this.isOutlined = false,
    this.isLoading = false,
    this.isBlock = false,
    this.isDisabled = false,
    super.key,
  });

  final Component child;
  final VoidCallback onPressed;
  final Color? color;
  final bool isBlock;
  final bool isOutlined;
  final bool isLoading;
  final bool isDisabled;

  @override
  Component build(BuildContext context) {
    return button(
      classes:
          'button'
          '${color != null ? ' is-${color!.name}' : ''}'
          '${isOutlined ? ' is-outlined' : ''}'
          '${isLoading ? ' is-loading' : ''}'
          '${isBlock ? ' block' : ''}',
      disabled: isDisabled,
      onClick: onPressed,
      [child],
    );
  }
}

class IconLabel extends StatelessComponent {
  const IconLabel({required this.icon, required this.label, super.key});

  final String icon;
  final String label;

  @override
  Component build(BuildContext context) {
    return .fragment([
      span(classes: 'icon', [i(classes: 'fas fa-$icon', [])]),
      span([.text(label)]),
    ]);
  }
}

/// Bulma Button Group Component
class ButtonGroup extends StatelessComponent {
  const ButtonGroup({required this.children, this.isAttached = false, super.key});

  final List<Button> children;
  final bool isAttached;

  @override
  Component build(BuildContext context) {
    return div(classes: 'buttons ${isAttached ? ' has-addons' : ''} block', children);
  }
}
