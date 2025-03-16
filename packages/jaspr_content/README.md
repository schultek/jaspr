
## jaspr_content

A package for building content-driven sites with Jaspr.


## Usage

Requires `static` or `server` mode.

A minimal setup looks like this:

```dart
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';

void main() {
  Jaspr.initializeApp();

  runApp(ContentApp(
    parsers: [
      // Enables parsing markdown files.
      MarkdownParser(),
    ],
    layouts: [
      // An empty layout that renders only the content.
      EmptyLayout(),
    ],
  ));
}
```

---

A setup for documentation sites might look like this:

```dart
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';

void main() {
  Jaspr.initializeApp();

  runApp(ContentApp.custom(
    loaders: [
      FilesystemLoader('content'),
      GithubLoader(
        'schultek/jaspr',
        accessToken: '...',
      ),
    ],
    configResolver: PageConfig.resolve(
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
            title: 'Jaspr',
            logo: 'assets/logo.png',
            items: [
              ThemeToggle(),
              GithubButton(repo: 'schultek/jaspr'),
            ]
          ),
          sidebar: Sidebar(groups: [
            SidebarGroup(
              links: [
                SidebarLink(text: "\uD83D\uDCD6 Overview", href: '/'),
                SidebarLink(text: "\uD83E\uDD4A About", href: '/about'),
              ],
            ),
            SidebarGroup(title: 'Get Started', links: [
              SidebarLink(text: "\uD83D\uDCDF Rendering Modes", href: '/get_started/modes'),
              SidebarLink(text: "\uD83D\uDCA7 Hydration", href: '/get_started/hydration'),
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
```

There is **lots** more to discover. A good starting point is to check the documentation on `ContentApp`.

## Futher Ideas / Roadmap

- Add data loading mechanism

- Add a code block component
  - syntax highlighting
  - copy button
  - line numbers, diffing, etc.

- Add a blog layout

- Add a tabs component

