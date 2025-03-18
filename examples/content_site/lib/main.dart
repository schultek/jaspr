import 'dart:io';

import 'package:content_site/jaspr_options.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/components/theme_toggle.dart';
import 'package:jaspr_content/components/github_button.dart';
import 'package:jaspr_content/components/callout.dart';

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
      FilesystemLoader('content'),
      // GithubLoader(
      //   'schultek/jaspr',
      //   accessToken: Platform.environment['GITHUB_ACCESS_TOKEN'],
      // ),
      MemoryLoader(pages: [
        MemoryPage(
          path: 'robots.txt',
          content: 'This is a robots page.\n'
          'Path is: {{page.path}}\n'
          'Data is: {{info.what}}',
          data: {'test': 'This is a test'},
        )
      ])
    ],
    configResolver: (route) {
      if (route.path.endsWith('.txt')) {
        return PageConfig(
          dataLoaders: [
            FilesystemDataLoader('content/_data'),
          ],
          templateEngine: MustacheTemplateEngine(),
          enableRawOutput: true,
        );
      }

      return PageConfig(
        dataLoaders: [
          FilesystemDataLoader('content/_data'),
        ],
        templateEngine: MustacheTemplateEngine(),
        parsers: [
          MarkdownParser(),
        ],
        extensions: [
          TableOfContentsExtension(),
          HeadingAnchorExtension(),
          ComponentsExtension([
            Callout.factory,
          ]),
        ],
        layouts: [
          DocsLayout(
            favicon: 'favicon.ico',
            header: Header(
                title: 'Jasprs',
                logo: 'https://raw.githubusercontent.com/schultek/jaspr/refs/heads/main/assets/logo.png',
                items: [
                  ThemeToggle(),
                  GithubButton(repo: 'schultek/jaspr'),
                ]),
            sidebar: Sidebar(groups: [
              SidebarGroup(
                links: [
                  SidebarLink(text: "\uD83D\uDCD6 Overview", href: '/'),
                  SidebarLink(text: "\uD83E\uDD4A Jaspr vs Flutter Web", href: '/jaspr-vs-flutter-web'),
                  SidebarLink(text: "\uD83E\uDD4A About", href: '/about'),
                ],
              ),
              SidebarGroup(title: 'Get Started', links: [
                SidebarLink(text: "\uD83D\uDEEB Installation", href: '/get_started/installation'),
                SidebarLink(text: "\uD83D\uDD79 Jaspr CLI", href: '/get_started/cli'),
                SidebarLink(text: "\uD83D\uDCDF Rendering Modes", href: '/get_started/modes'),
                SidebarLink(text: "\uD83D\uDCA7 Hydration", href: '/get_started/hydration'),
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
      );
    },
  ));
}
