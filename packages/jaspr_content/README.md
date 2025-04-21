## jaspr_content

A package for building content-driven sites with Jaspr.

## Usage

> **Requires `static` or `server` mode!**

A minimal setup looks like this:

```dart
// lib/main.dart

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

Here already a bunch of stuff is happening behind the scenes:

1. The app analyzes the 'content' directory and builds a routing table of all files and folders.
   For example:
   - a file `content/index.md` will be available at `/`
   - a file `content/guides/routing.md` will be available at `guides/routing/`
2. The app will parse the markdown content of each file and render it into a Jaspr component, including some basic theming and typographic styles.  
   - 2.1. If the file contains frontmatter data, it too will be parsed. Data like a 'title' or 'description' will be rendered as html meta tags.
3. When building in static mode, the app will generate static html files for each markdown file at build time.
4. During development, the app watches the 'content' directory for changes and updates the routing table and content accordingly.

---

The default `ContentApp()` constructor is a good starting point for simple content-driven sites. It provides a basic setup for parsing and rendering content like markdown and is easy to setup.

However, what you have seen so far only scratches the surface of what is possible with `jaspr_content`. Almost every aspect of the content rendering process can be customized and extended. You may switch out any part of the process independently, configure it to your liking, or extend it with your own custom implementation for things like parsers and layouts.

For example, simply adding `HtmlParser()` to the list of parsers will enable parsing of html files inside the `content` directory.

Or changing the layout to `DocsLayout()` will give you a beautiful out-of-the-box documentation layout with a header, sidebar and table of contents - which of course all can be customized further.

If this still isn't enough, you can use the `ContentApp.custom()` constructor to get full control over every aspect of the content rendering process. This allows you to configure everything from the routing and page loading mechanism to the final layout and theme.

Most importantly, you can use `ContentApp.custom()` to switch out the default `FilesystemLoader` with the alternative `GithubLoader` to load content from a Github repository instead of a local directory.

Again it is imporant to note that even when switching out the underlying page loaders, everything else in the setup can stay the same. This is due to the modular design of `jaspr_content` which allows you to mix and match different parts however you like.

---

Instead of more talking, lets look at some code.

This is a setup for a documentation site loaded both from the local filesystem as well as a github repository. It uses features such as:

- Support for frontmatter data in all files.
- Additional data is loaded from `.json` and `.yaml` files in the local `content/_data` directory.
- Each file is pre-processed using the mustache templating language.
- The content is parsed from `.md` and `.html` files.
- A table of contents is auto-generated from the headings in the content.
- Each heading gets an anchor link for easy linking.
- Rendering of custom components from content such as `<Info>...</Info>` or `<Success>...</Success>`.
- The page is rendered in a documentation layout including:
  - a header with a title and logo
  - a toggle to switch between light and dark mode
  - a sidebar with links to different pages
- Custom primary and background colors with both light and dark variants.

```dart
// lib/main.dart
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
      dataLoaders: [
        FilesystemDataLoader('content/_data'),
      ],
      templateEngine: MustacheTemplateEngine(),
      parsers: [
        HtmlParser(),
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
              SidebarLink(text: "\uD83D\uDCA7 Server vs Client", href: '/get_started/server_client'),
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

There is **lots** more to discover. A good starting point is to check the code documentation on `ContentApp`.

---

If you want to make sure to understand all concepts, here is a full list of all major parts and their purpose. Also checkout their respective code documentation for more details.

- **ContentApp**: The main entry point for setting up a content-driven site.
- **Page**: A data object that holds all information and configuration about a single page. A page is what will be rendered to a `.html` file.
- **PageConfig**: A configuration object that holds all settings for parsing and rendering content. This may either be applied to a single page (where different pages have different PageConfigs) or to the whole app.
- **RouteLoader**: Loads pages from a sources like the filesystem or a github repository.
- **DataLoader**: Loads additional data from sources like `.json` or `.yaml` files.
- **TemplateEngine**: Pre-processes the content using a templating language like mustache. This is useful for injecting data (from frontmatter and data loaders) into the content before parsing.
- **PageParser**: Parses the content from a file format like markdown or html.
- **PageExtension**: Post-processes a page after parsing. This may analyze and modify the page in many different ways and is useful for adding features like custom components or a table of contents.
- **PageLayout**: Renders a page's content into a final html layout. This may include any additional ui elements like a header, sidebar, or footer. Multiple layouts are supported, and a page may choose a different layout than the default one.
- **ContentTheme**: Defines the theme colors and typographic styles for the site. This includes primary and background colors, light and dark variants as well as font sizes and styles for headers, paragraphs and more.
