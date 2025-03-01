import 'package:content_site/jaspr_options.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/counter.dart';

void main() {
  Jaspr.initializeApp(options: defaultJasprOptions);

  runApp(ContentApp(
    eagerlyLoadAllPages: false,
    templateEngine: MustacheTemplateEngine(),
    parsers: [
      HtmlParser(),
      MarkdownParser(),
    ],
    extensions: [
      TableOfContentsExtension(),
      ComponentsExtension({
        'Badge': (attrs, child) => Badge(color: Color.named(attrs['color'] ?? 'blue'), child: child),
        'Counter': (_, __) => Counter(),
      }),
    ],
    layouts: [
      DefaultLayout(),
    ],
  ));
}

void runGithub() {
  runApp(ContentApp.custom(
    loader: GithubLoader(
      'schultek/jaspr',
      accessToken: '...',
    ),
    configResolver: PageConfig.resolve(
      templateEngine: MustacheTemplateEngine(),
      parsers: [
        HtmlParser(),
        MarkdownParser(),
      ],
      extensions: [
        TableOfContentsExtension(),
        ComponentsExtension({
          'Badge': (attrs, child) => Badge(color: Color.named(attrs['color'] ?? 'blue'), child: child),
          'Counter': (_, __) => Counter(),
        }),
      ],
      layouts: [
        DefaultLayout(),
      ],
    ),
    routerBuilder: (routes) {
      return Router(routes: [
        //Route(path: '/', builder: (_, __) => Text('Home')),
        ...routes,
      ]);
    },
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

class DefaultLayout implements PageLayout {
  const DefaultLayout();

  @override
  String get name => 'default';

  @override
  Component buildLayout(Page page, Component child) {
    final title = page.data['title'];
    final toc = page.data['toc'];

    return Document(
      title: title != null ? '$title | My Site' : 'My Site',
      lang: 'en',
      body: Fragment(children: [
        main_([
          child,
        ]),
        if (toc case List<TocEntry> toc)
          aside(classes: 'toc', [
            ul([..._buildToc(toc)]),
          ]),
      ]),
    );
  }

  Iterable<Component> _buildToc(List<TocEntry> toc, [int indent = 0]) sync* {
    for (final entry in toc) {
      yield li(styles: Styles(padding: Padding.only(left: (0.75 * indent).em)), [
        a(href: '#${entry.id}', [text(entry.text)]),
      ]);
      if (entry.children.isNotEmpty) {
        yield* _buildToc(entry.children, indent + 1);
      }
    }
  }
}
