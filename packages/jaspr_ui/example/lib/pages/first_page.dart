import 'package:jaspr/jaspr.dart';
import 'package:jaspr/ui.dart';
import 'package:jaspr_ui/bootstrap.dart';

class FirstPage extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DivElement(
      classes: ['container'],
      child: DivElement(
        classes: ['row'],
        children: [
          Paragraph("Hello world!!"),
          Center(child: Button.basic(text: "test123")),
          Size(height: "25px"),
          DivElement(
            children: [
              ButtonElement(text: "test123"),
              Button(text: "test123"),
              Button(text: "test123", type: ButtonType.danger),
            ],
          ),
          Size(height: "25px"),
          Center(
            child: Image(
              source: "https://metacode.biz/@test/avatar.jpg",
              alternate: "Test image",
            ),
          ),
          //Carousel(),
        ],
      ),
    );
    /*
    yield DomComponent(
      tag: 'table',
      styles: {'width': "100%", 'border': '1px solid black'},
      child: DomComponent(tag: 'tr', children: [
        DomComponent(
          tag: 'td',
          child: DomComponent(
            tag: 'div',
            styles: {'margin': "auto auto"},
            classes: ['container'],
            children: [
              Paragraph("Hello world!!"),
              Button("test123"),
            ],
          ),
        ),
        DomComponent(
          tag: 'td',
          child: DomComponent(
            tag: 'div',
            styles: {'margin': "0 0"},
            classes: ['container'],
            children: [
              Paragraph("Hello world!!"),
              Button("test123"),
            ],
          ),
     */
  }
}
