import 'package:jaspr/jaspr.dart';

class Paragraph extends StatelessComponent {
  final String text;
  final Map<String, String>? styles;
  final List<String>? classes;

  Paragraph(this.text, {this.styles, this.classes});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'p',
      styles: styles,
      classes: classes,
      child: Text(text),
    );
  }
}
