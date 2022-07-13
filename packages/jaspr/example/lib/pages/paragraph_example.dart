import 'package:jaspr/jaspr.dart';
import 'package:jaspr/ui.dart';

class NewParagraphExample extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DivElement(
      children: [
        Header('This is a title', size: HeaderSize.h1),
        Paragraph(
          children: [
            Text('Hello '),
            TextSpan(
              child: Text('World!'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class OldParagraphExample extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      children: [
        DomComponent(
          tag: 'h1',
          child: Text('This is a title'),
        ),
        DomComponent(
          tag: 'p',
          children: [
            Text('Hello '),
            DomComponent(
              tag: 'i',
              child: DomComponent(
                tag: 'b',
                child: Text('World!'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
