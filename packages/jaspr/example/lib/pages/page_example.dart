import 'package:jaspr/jaspr.dart';
import 'package:jaspr/ui.dart';

class PageExample extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DivElement(
      classes: ['container'],
      child: DivElement(
        classes: ['row'],
        children: [
          Paragraph(child: Text("Hello world!!")),
          Center(child: ButtonElement(text: "test123")),
          Box(height: Pixels(50)),
          DivElement(
            children: [
              ButtonElement(text: "test123"),
              ButtonElement(text: "test123", style: BackgroundStyle(color: Color.fromName(Colors.lightBlue))),
              ButtonElement(text: "test123", style: ColorStyle(Color.fromName(Colors.hotPink))),
            ],
          ),
          Box(height: Pixels(50)),
          Center(
            child: Image(
              source: "https://metacode.biz/@test/avatar.jpg",
              alternate: "Test image",
            ),
          ),
          Link(
            href: "https://www.google.com/",
            target: LinkTarget.blank,
            child: Text("Google link"),
          ),
          Center(
            child: Box(
              width: Pixels(200),
              child: ListView(
                  //insideMarkers: true,
                  style: MultipleStyle(styles: [
                    BackgroundStyle(
                      color: Color.fromName(Colors.greenYellow),
                      gradient: RadialGradient(
                        circle: Circle(
                          position: PositionEnum.bottomRight,
                          size: Pixels(200),
                        ),
                        color1: Color.fromName(Colors.red),
                        color2: Color.fromName(Colors.green),
                        color3: Color.fromName(Colors.blue),
                      ),
                    ),
                    TextStyle(align: TextAlign.left)
                  ]),
                  ordered: true,
                  children: [
                    ListItem(
                      child: Box(
                        height: Pixels(20),
                        width: Pixels(50),
                        padding: EdgeInsets.symmetric(vertical: Pixels(30)),
                        child: Text("test1"),
                      ),
                    ),
                    ListItem(child: Text("test2")),
                    ListItem(child: Text("test3")),
                    ListItem(child: Text("test4")),
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
