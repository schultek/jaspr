import 'package:jaspr/jaspr.dart';

class Paragraph extends StatelessComponent {
  final String text;

  Paragraph(this.text);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'p',
      child: Text(text),
    );
  }
}
