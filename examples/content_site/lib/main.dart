import 'package:content_site/clicker.dart';
import 'package:content_site/jaspr_options.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/components/code_block.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/components/theme_toggle.dart';
import 'package:jaspr_content/components/github_button.dart';
import 'package:jaspr_content/components/post_break.dart';
import 'package:jaspr_content/components/callout.dart';
import 'package:jaspr_content/components/drop_cap.dart';
import 'package:jaspr_content/components/image.dart';
import 'package:jaspr_content/components/tabs.dart';

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

void runGithub() {
  runApp(ContentApp.custom(
    loaders: [
      FilesystemLoader('content', keeySuffixPattern: RegExp(r'.*\.txt$')),
      // GithubLoader(
      //   'schultek/jaspr',
      //   accessToken: Platform.environment['GITHUB_ACCESS_TOKEN'],
      // ),
      MemoryLoader(pages: [
        MemoryPage(
          path: 'robots.txt',
          keepSuffix: true,
          content: '''
            This is a robots file
            Data is: {{info.what}}
          ''',
        ),
        MemoryPage.builder(
          path: 'about/me',
          builder: (page) {
            print(page.data);
            return page.wrapTheme(page.buildLayout(Content(text('hi'))));
          },
        )
      ])
    ],
    eagerlyLoadAllPages: true,
    configResolver: PageConfig.all(
      dataLoaders: [
        FilesystemDataLoader('content/_data'),
      ],
      templateEngine: MustacheTemplateEngine(),
      rawOutputPattern: RegExp(r'.*\.txt'),
      secondaryOutputs: [SecondaryMarkdownOutput()],
      parsers: [
        MarkdownParser(),
        HtmlParser(),
      ],
      extensions: [
        TableOfContentsExtension(),
        //HeadingAnchorsExtension(),
      ],
      components: [
        Callout(),
        DropCap(),
        PostBreak(),
        Image(zoom: true),
        CodeBlock(),
        Tabs(),
        CustomComponent(
          pattern: 'Clicker',
          builder: (_, __, ___) => Clicker(),
        ),
      ],
      layouts: [
        //EmptyLayout(),
        // BlogLayout(
        //   header: Header(
        //     title: 'Jaspr Blog',
        //     logo: 'https://raw.githubusercontent.com/schultek/jaspr/refs/heads/main/assets/logo.png',
        //     items: [
        //       ThemeToggle(),
        //       GithubButton(repo: 'schultek/jaspr'),
        //     ],
        //   ),
        // ),
        DocsLayout(
          header: Header(
            title: 'Jaspr',
            logo: 'https://raw.githubusercontent.com/schultek/jaspr/refs/heads/main/assets/logo.png',
            items: [
              ThemeToggle(),
              GithubButton(repo: 'schultek/jaspr'),
            ],
          ),
          sidebar: Sidebar(groups: [
            SidebarGroup(
              links: [
                SidebarLink(text: "Overview", href: '/docs'),
              ],
            ),
            SidebarGroup(title: 'Get Started', links: [
              SidebarLink(text: "Quickstart", href: '/get_started/quick_start'),
              SidebarLink(text: "Installation", href: '/get_started/installation'),
            ]),
          ]),
        ),
      ],
      // theme: ContentTheme(
      //   primary: ThemeColor(Color('#01589B'), dark: Color('#41C3FE')),
      //   background: ThemeColor(Colors.white, dark: Color('#0b0d0e')),
      // ),
    ),
  ));
}
