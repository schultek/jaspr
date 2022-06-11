import 'package:jaspr/jaspr.dart';

class ButtonElement extends StatelessComponent {
  final String text;
  final List<String>? classes;

  const ButtonElement({required this.text, this.classes});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'button',
      classes: classes,
      child: Text(text),
    );
  }
}
