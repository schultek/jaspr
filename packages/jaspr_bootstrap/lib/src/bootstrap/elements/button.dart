import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/core.dart';

enum ButtonType {
  primary,
  secondary,
  success,
  danger,
  warning,
  info,
  light,
  dark,
  link,
}

class Button extends ButtonElement {
  final ButtonType? type;

  const Button({
    super.id,
    super.key,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
    required super.text,
    this.type = ButtonType.primary,
  });

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield ButtonElement(
      text: text,
      classes: type != null ? ['btn', 'btn-${type!.name}'] : [],
    );
  }

  factory Button.basic({required String text}) {
    return Button(text: text, type: null);
  }
}
