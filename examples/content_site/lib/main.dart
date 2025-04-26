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
      ],
      extensions: [
        //TableOfContentsExtension(),
        HeadingAnchorExtension(),
      ],
      components: [
        Callout(),
        DropCap(),
        PostBreak(),
        Image(zoom: true),
        CodeBlock(),
        Tabs(),
      ],
      layouts: [
        //EmptyLayout(),
        // BlogLayout(
        //   header: Header(
        //     title: 'Jasprs',
        //     logo: 'https://raw.githubusercontent.com/schultek/jaspr/refs/heads/main/assets/logo.png',
        //     items: [
        //       GithubButton(repo: 'schultek/jaspr'),
        //     ],
        //   ),
        // ),
        DocsLayout(
          header: Header(
            title: 'Jasprs',
            logo: 'https://raw.githubusercontent.com/schultek/jaspr/refs/heads/main/assets/logo.png',
            items: [
              ThemeToggle(),
              GithubButton(repo: 'schultek/jaspr'),
            ],
          ),
          sidebar: Sidebar(groups: [
            SidebarGroup(
              links: [
                SidebarLink(text: "\uD83D\uDCD6 Overview", href: '/'),
                SidebarLink(text: "\uD83E\uDD4A Jaspr vs Flutter Web", href: '/jaspr-vs-flutter-web'),
                SidebarLink(text: "\uD83E\uDD4A About", href: '/about'),
              ],
            ),
            SidebarGroup(title: 'Get Started', links: [
              SidebarLink(text: "\uD83D\uDEEB Quickstart", href: '/get_started/quick_start'),
              SidebarLink(text: "\uD83D\uDCDF Rendering Modes", href: '/get_started/modes'),
              SidebarLink(text: "\uD83D\uDCA7 Server vs Client", href: '/get_started/server_client'),
              SidebarLink(text: "\uD83D\uDD79 Jaspr CLI", href: '/get_started/cli'),
              SidebarLink(text: "\uD83D\uDCE6 Project Structure", href: '/get_started/project_structure'),
              SidebarLink(text: "\uD83E\uDDF9 Linting", href: '/get_started/linting'),
            ]),
          ]),
        ),
      ],
      theme: ContentTheme(
        primary: ThemeColor(Color('#01589B'), dark: Color('#41C3FE')),
        background: ThemeColor(Colors.white, dark: Color('#0b0d0e')),
      ),
    ),
  ));
}
