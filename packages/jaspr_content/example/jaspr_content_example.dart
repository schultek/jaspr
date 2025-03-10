import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';

void main() {
  Jaspr.initializeApp();

  runApp(ContentApp(
    templateEngine: MustacheTemplateEngine(),
    parsers: [
      HtmlParser(),
      MarkdownParser(),
    ],
    // Enables using custom components like '<Badge color="red">Hello</Badge>'.
    extensions: [
      ComponentsExtension({
        'Badge': (attrs, child) => Badge(color: Color.named(attrs['color'] ?? 'blue'), child: child),
      }),
    ],
    // Enables using 'layout: ___' in frontmatter to choose the page layout.
    layouts: [
      EmptyLayout(),
    ],
  ));
}

class Badge extends StatelessComponent {
  Badge({required this.color, this.child});

  final Color color;
  final Component? child;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield span(classes: 'badge', styles: Styles(color: color), [
      if (child != null) child!,
    ]);
  }

  @css
  static final styles = [
    css('.badge').styles(
      display: Display.inlineBlock,
      padding: Padding.symmetric(vertical: 0.25.em, horizontal: 0.5.em),
      radius: BorderRadius.circular(0.25.em),
    ),
  ];
}