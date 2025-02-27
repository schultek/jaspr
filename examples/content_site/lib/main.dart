import 'package:content_site/jaspr_options.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';

import 'components/counter.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultJasprOptions,
    useIsolates: false,
  );

  runApp(ContentApp(
    eagerlyLoadAllPages: false,
    config: PageConfig(
      templateEngine: MustacheTemplateEngine(),
      components: ComponentsConfig(components: {
        'Badge': (attrs, child) => Badge(color: Color.named(attrs['color'] ?? 'blue'), child: child),
        'Counter': (_, __) => Counter(),
      }),
      layouts: LayoutsConfig(
        defaultLayout: (child) => DefaultLayout(child: child),
      ),
    ),
    builders: [
      MarkdownPageBuilder(),
      HtmlPageBuilder(),
    ],
  ));
}

class Badge extends StatelessComponent {
  Badge({required this.color, required this.child});

  final Color color;
  final Component child;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield span(classes: 'badge', styles: Styles(color: color), [
      child,
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

class DefaultLayout extends StatelessComponent {
  const DefaultLayout({required this.child});

  final Component child;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Document(
      title: context.page.data['title'] != null ? '${context.page.data['title']} | My Site' : 'My Site',
      lang: 'en',
      body: main_([
        div([
          text('Pages: ${context.pages.map((p) => (p.path, p.data)).join(', ')}'),
        ]),
        child,
      ]),
    );
  }
}
