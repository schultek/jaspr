import 'package:jaspr/jaspr.dart';

enum ButtonType {
  primary,
  secondary,
  success,
  danger,
  warning,
  info,
  light,
  dark,
  link
}

class Button extends StatelessComponent {
  final ButtonType type;
  final String text;

  Button(this.text, {this.type = ButtonType.primary});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'button',
      classes: ['btn', 'btn-${type.name}'],
      child: Text(text),
    );
  }
}
