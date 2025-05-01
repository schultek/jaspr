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
      secondaryOutputs: [
        SecondaryMarkdownOutput(),
        SecondaryImageOutput(builder: (page) {
          return svg(width: 1200.px, height: 630.px, [
            Style(styles: [
              css('*').styles(
                  fontFamily: FontFamily.list([
                FontFamily('Open Sans'),
                FontFamilies.uiSansSerif,
                FontFamilies.systemUi,
                FontFamilies.sansSerif,
              ])),
            ]),
              rect(x: "0", y: "0", width: "100%", height: "100%", fill: ContentColors.background.dark!, []),
              circle(cx: "50", cy: "50", r: "40", fill: Colors.purple, []),
              raw('''
          <image
            x="290"
            y="100"
            width="128"
            height="146"
            href="../../assets/logo.svg" />

            <defs>
              <filter id="blendColor">
                <feFlood flood-color="hsl(0, 100%, 50%)" />
                <feComposite in2="SourceGraphic" operator="in" />
              </filter>
            </defs>
            <g align="center">
            <image
            x="0"
            y="20"
            width="32"
            height="32"
            filter="url(#blendColor)"
            href="../../assets/icon.svg" />
              <text x="80" y="70" font-size="100" font-weight="800"  fill="white">
                Jaspr
              </text>
            </g>
            <g align="top left" fill="pink"><text>Top Left</text></g>
            <g align="top center" fill="pink"><text>Top Center</text></g>
            <g align="top right" fill="pink"><text>Top Right</text></g>
            <g align="center left" fill="pink"><text>Center Left</text></g>
            <g align="center center" fill="pink"><text>Center</text></g>
            <g align="center right" fill="pink"><text>Center Right</text></g>
            <g align="bottom left" fill="pink"><text>Bottom Left</text></g>
            <g align="bottom center" fill="pink"><text>Bottom Center</text></g>
            <g align="bottom right" fill="pink"><text>Bottom Right</text></g>
            <g align="left" fill="pink">
              <rect x="0" y="0" width="1" height="1" fill="transparent"/>
              <circle cx="70" cy="40" r="40" fill="blue"/>
            </g>
            <circle cx="-50" cy="20" r="40" fill="purple" align="right"/>
        '''),
          ]);
        }),
      ],
      parsers: [
        MarkdownParser(),
      ],
      extensions: [
        TableOfContentsExtension(),
        //HeadingAnchorExtension(),
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
