import 'package:content_site/jaspr_options.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/components/github_button.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/layouts/docs_layout.dart';

import 'components/counter.dart';

void main() {
  Jaspr.initializeApp(options: defaultJasprOptions);
  runGithub();
  return;
}

@css
List<StyleRule> get globalStyles => [
      css('.flex').styles(display: Display.flex),
      css('.justify-center').styles(justifyContent: JustifyContent.center),
    ];

void runLocal() {
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
    loaders: [
      FilesystemLoader('content'),
      GithubLoader(
        'schultek/jaspr',
        accessToken: '...',
      ),
    ],
    configResolver: PageConfig.resolve(
      templateEngine: MustacheTemplateEngine(),
      parsers: [
        HtmlParser(),
        MarkdownParser(),
      ],
      extensions: [
        TableOfContentsExtension(),
        ComponentsExtension({
          'Github': (_, __) => GithubButton(repo: 'schultek/jaspr'),
        }),
      ],
      layouts: [
        DocsLayout(
          title: 'Jaspr',
          logo: 'https://raw.githubusercontent.com/schultek/jaspr/refs/heads/main/assets/logo.png',
          favicon: 'favicon.ico',
          sidebar: Sidebar(groups: [
            SidebarGroup(
              items: [
                SidebarItem(text: "\uD83D\uDCD6 Overview", href: '/'),
                SidebarItem(text: "\uD83E\uDD4A Jaspr vs Flutter Web", href: '/jaspr-vs-flutter-web'),
              ],
            ),
            SidebarGroup(title: 'Get Started', items: [
              SidebarItem(text: "\uD83D\uDEEB Installation", href: '/get_started/installation'),
              SidebarItem(text: "\uD83D\uDD79 Jaspr CLI", href: '/get_started/cli'),
              SidebarItem(text: "\uD83D\uDCDF Rendering Modes", href: '/get_started/modes'),
              SidebarItem(text: "\uD83D\uDCA7 Hydration", href: '/get_started/hydration'),
              SidebarItem(text: "\uD83D\uDCE6 Project Structure", href: '/get_started/project_structure'),
              SidebarItem(text: "\uD83E\uDDF9 Linting", href: '/get_started/linting'),
            ]),
          ]),
        ),
      ],
    ),
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
