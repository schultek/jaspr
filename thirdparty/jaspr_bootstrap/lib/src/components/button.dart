import 'package:jaspr/ui.dart';

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
    super.style,
    classes,
    super.attributes,
    super.events,
    required super.text,
    this.type = ButtonType.primary,
  });

  @override
  List<String> getClasses() => type != null ? ['btn', 'btn-${type!.name}'] : [];

  factory Button.basic({required String text}) {
    return Button(text: text, type: null);
  }
}
