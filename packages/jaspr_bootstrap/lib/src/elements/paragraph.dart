import 'package:jaspr/jaspr.dart';

class Paragraph extends StatelessComponent {
  final String text;
  final Map<String, String>? styles;

  Paragraph(this.text, {this.styles});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'p',
      styles: styles,
      child: Text(text),
    );
  }
}
