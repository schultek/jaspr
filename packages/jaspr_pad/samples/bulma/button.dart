import 'package:jaspr/jaspr.dart' hide Color;

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
    Key? key,
  }) : super(key: key);

  final Component child;
  final VoidCallback onPressed;
  final Color? color;
  final bool isBlock;
  final bool isOutlined;
  final bool isLoading;
  final bool isDisabled;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'button',
      classes: [
        'button',
        if (color != null) 'is-${color!.name}',
        if (isOutlined) 'is-outlined',
        if (isLoading) 'is-loading',
        if (isBlock) 'block',
      ],
      attributes: {if (isDisabled) 'disabled': ''},
      events: {
        'click': (e) => onPressed(),
      },
      child: child,
    );
  }
}

class IconLabel extends StatelessComponent {
  const IconLabel({required this.icon, required this.label, Key? key}) : super(key: key);

  final String icon;
  final String label;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
        tag: 'span',
        classes: ['icon'],
        child: DomComponent(
          tag: 'i',
          classes: ['fas', 'fa-$icon'],
        ));
    yield DomComponent(
      tag: 'span',
      child: Text(label),
    );
  }
}

/// Bulma Button Group Component
class ButtonGroup extends StatelessComponent {
  const ButtonGroup({required this.children, this.isAttached = false, Key? key}) : super(key: key);

  final List<Button> children;
  final bool isAttached;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: ['buttons', if (isAttached) 'has-addons', 'block'],
      children: children,
    );
  }
}
