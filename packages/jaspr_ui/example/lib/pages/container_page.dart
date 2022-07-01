import 'package:jaspr/jaspr.dart';
import 'package:jaspr/ui.dart';
import 'package:jaspr_ui/bootstrap.dart';

class ContainerPage extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield HorizontalLine();
    yield Container(
      children: [
        Header("This is a heading", size: HeaderSize.h1),
        Paragraph("This is a paragraph of text."),
      ],
    );
    yield HorizontalLine();
    yield Container(
      breakpoint: Breakpoint.fluid,
      children: [
        Header("This is a heading", size: HeaderSize.h1),
        Paragraph("This is a paragraph of text."),
      ],
    );
    yield HorizontalLine();
    yield Container(
      breakpoint: Breakpoint.small,
      child: Text("100% wide until screen size less than 576px"),
    );
    yield Container(
      breakpoint: Breakpoint.medium,
      child: Text("100% wide until screen size less than 768px"),
    );
    yield Container(
      breakpoint: Breakpoint.large,
      child: Text("100% wide until screen size less than 992px"),
    );
    yield Container(
      breakpoint: Breakpoint.extraLarge,
      child: Text("100% wide until screen size less than 1200px"),
    );
    yield HorizontalLine();
    yield Container(
      backgroundColor: BackgroundColor.dark,
      textColor: TextColor.white,
      border: Border(),
      padding: EdgeInsets.symmetric(vertical: Space.s3),
      margin: EdgeInsets.symmetric(vertical: Space.s3),
      children: [
        Header("This is a heading", size: HeaderSize.h1),
        Paragraph("This is a paragraph of text."),
      ],
    );
    yield Container(
      backgroundColor: BackgroundColor.light,
      padding: EdgeInsets.symmetric(vertical: Space.s3),
      margin: EdgeInsets.symmetric(vertical: Space.s3),
      children: [
        Header("This is a heading", size: HeaderSize.h1),
        Paragraph("This is a paragraph of text."),
      ],
    );
    yield Container(
      border: Border(edge: BorderEdge.all()),
      padding: EdgeInsets.symmetric(vertical: Space.s3),
      margin: EdgeInsets.symmetric(vertical: Space.s3),
      children: [
        Header("This is a heading", size: HeaderSize.h1),
        Paragraph("This is a paragraph of text."),
      ],
    );
    yield HorizontalLine();
    yield Container(
      border: Border(
        edge: BorderEdge.all(),
        color: BorderColor.primary,
        round: BorderRound.all,
        radius: BorderRadius.r5,
        width: BorderWidth.w4,
        opacity: BorderOpacity.o25,
      ),
      padding: EdgeInsets.symmetric(vertical: Space.s3),
      margin: EdgeInsets.symmetric(vertical: Space.s3),
      children: [
        Header("This is a heading", size: HeaderSize.h1),
        Paragraph("This is a paragraph of text."),
      ],
    );
    yield HorizontalLine();
  }
}
