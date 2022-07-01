import 'package:jaspr/jaspr.dart';
import 'package:jaspr/ui.dart';

class FirstPage extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DivElement(
      classes: ['container'],
      child: DivElement(
        classes: ['row'],
        children: [
          Paragraph(child: Text("Hello world!!")),
          Center(child: ButtonElement(text: "test123")),
          Size(height: "50px"),
          DivElement(
            children: [
              ButtonElement(text: "test123"),
              ButtonElement(text: "test123"),
              ButtonElement(text: "test123", style: Style('color', 'red')),
            ],
          ),
          Size(height: "50px"),
          Center(
            child: Image(
              source: "https://metacode.biz/@test/avatar.jpg",
              alternate: "Test image",
            ),
          ),
        ],
      ),
    );
  }
}
