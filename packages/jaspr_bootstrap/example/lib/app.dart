import 'package:jaspr/jaspr.dart';
import 'package:jaspr_bootstrap/jaspr_bootstrap.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: ['container'],
      child: DomComponent(
        tag: 'div',
        classes: ['row'],
        children: [
          Paragraph("Hello world!!"),
          Center(child: Button("test123")),
          Size(height: "25px"),
          DomComponent(
            tag: 'div',
            child: Button("test123"),
          ),
          Size(height: "25px"),
          Center(
            child: Image(
              source: "https://metacode.biz/@test/avatar.jpg",
              description: "Test image",
              width: 25,
            ),
          ),
          Carousel(),
        ],
      ),
    );
  }
}