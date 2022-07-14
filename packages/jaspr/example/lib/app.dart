import 'package:example/pages/page_example.dart';
import 'package:example/pages/form_example.dart';
import 'package:example/pages/paragraph_example.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/ui.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield ExampleBlock(
      title: "Simple page example:",
      body: PageExample(),
    );

    yield ExampleBlock(
      title: "Basic text example:",
      body: DivElement(children: [
        NewParagraphExample(),
        OldParagraphExample(),
      ]),
    );

    yield ExampleBlock(
      title: "Basic form example:",
      body: FormExample(),
    );
  }
}

class ExampleBlock extends StatelessComponent {
  final String title;
  final Component body;

  ExampleBlock({
    required this.title,
    required this.body,
  });

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Header(title, size: HeaderSize.h2);

    yield body;

    yield Box(height: Pixels(50));
    yield HorizontalLine();
    yield Box(height: Pixels(50));
  }
}
