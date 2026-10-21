---
name: jaspr-content
description: Build content-driven websites (documentation, blogs, marketing sites, knowledge bases) using jaspr_content. Covers ContentApp setup, markdown/HTML parsing, frontmatter, data loading, layouts (DocsLayout, BlogLayout), built-in and custom markdown components, theming with tokens, templating, page extensions, and secondary outputs (RSS, raw markdown).
---

# jaspr_content

`jaspr_content` is the official package for building content-driven sites (documentation portals, blogs, knowledge bases, marketing pages) in Jaspr. It compiles Markdown and HTML files into typed Jaspr components, supports structured YAML frontmatter, custom layouts, component embeddings, theme tokens, and static site generation (SSG).

---

## 1. Project Setup & Architecture

### Core Rules

1. **Server-Side Pipeline:** `ContentApp` runs on the server during SSG/SSR (`lib/main.server.dart`). It maps files from `content/` to web routes, parses markdown/HTML into AST nodes, wraps them in layouts, and renders HTML.
2. **Specific Imports:**
   - **Core App & Layouts:** `import 'package:jaspr_content/jaspr_content.dart';`
   - **Theming & Tokens:** `import 'package:jaspr_content/theme.dart';` (safe for both server and client components).
   - **Built-in UI Components:** MUST be imported individually from `package:jaspr_content/components/<name>.dart`.
3. **No Isolates:** `ContentApp` relies on server-side caching. Do NOT set `Jaspr.initializeApp(useIsolates: true)` with `ContentApp`.

### Recommended Setup

```dart title="lib/main.server.dart"
import 'package:jaspr/server.dart';
import 'package:jaspr_content/components/callout.dart';
import 'package:jaspr_content/components/code_block.dart';
import 'package:jaspr_content/components/image.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/theme.dart';

import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(
    ContentApp(
      parsers: [MarkdownParser()],
      extensions: [
        HeadingAnchorsExtension(),
        TableOfContentsExtension(),
      ],
      components: [
        Callout(),
        CodeBlock(),
        Image(zoom: true),
      ],
      layouts: [
        DocsLayout(),
      ],
      theme: ContentTheme(
        primary: ThemeColor(ThemeColors.blue.$500, dark: ThemeColors.blue.$300),
        background: ThemeColor(ThemeColors.slate.$50, dark: ThemeColors.zinc.$950),
      ),
    ),
  );
}
```

### Directory Structure & Route Mapping

- `content/index.md` $\to$ `/`
- `content/about.md` $\to$ `/about`
- `content/guides/intro.md` $\to$ `/guides/intro`
- `content/blog/index.md` $\to$ `/blog`

#### Dos and Don'ts:
- **DO** prefix non-page directories and files with an underscore `_` (e.g. `content/_data/`, `content/_partials/`). Files/folders starting with `_` are automatically ignored by route discovery.
- **DO NOT** place draft or auxiliary files in `content/` without an `_` prefix, or they will be exposed as public routes.

---

## 2. Frontmatter & Page Data

Every markdown or HTML document can include YAML frontmatter at the top:

```markdown
---
title: Getting Started with Jaspr
description: Learn how to set up your first Jaspr Content project.
layout: docs
date: 2026-10-21
author: Kilian Schulte
tags: ["jaspr", "web", "dart"]
---

# {{ page.title }}

Written by {{ page.author }} on {{ page.date }}.
```

### Accessing Page Data in Components

Inside components rendered within `ContentApp`, access page metadata via `context.page`:

```dart
class ArticleHeader extends StatelessComponent {
  const ArticleHeader({super.key});

  @override
  Component build(BuildContext context) {
    // Only call context.page on the server
    final page = context.page;
    final title = page.data.page['title'] as String? ?? 'Untitled';
    final date = page.data.page['date'] as String?;

    return header(classes: 'article-header', [
      h1([.text(title)]),
      if (date != null) span([.text(date)]),
    ]);
  }
}
```

#### Dos and Don'ts:
- **DO** access `context.page` and `context.pages` strictly in Server Components or server-only build methods.
- **DO NOT** call `context.page` or `context.pages` inside client components (`@client`) or browser code. It throws an `UnsupportedError`. If shared code must check it, guard with `if (!kIsWeb)`.
- **DO** access frontmatter keys via `page.data.page['<key>']` (namespaced under `page`).
- **DO** use `date` as an ISO string or formatted date string in frontmatter. Avoid arbitrary custom ordering fields when standard dates apply.

---

## 3. Page Layouts (`PageLayout`)

Layouts define the visual shell (header, sidebar, TOC, footer) wrapping your content. A page selects its layout via `layout: <name>` in frontmatter.

### Built-in Layouts

1. **`DocsLayout`**: Includes header, sidebar navigation, and automatic right-hand Table of Contents (when `TableOfContentsExtension()` is enabled).
2. **`BlogLayout`**: Includes header, automatic article title block (using `title`, `author`, `date`, `readTime`, `authorImage` frontmatter keys), and tag list (`tags`).
3. **`EmptyLayout`**: Renders raw content without any wrapping layout chrome (useful for landing pages).

### Registering Layouts

```dart
ContentApp(
  layouts: [
    // The first layout in the list is the DEFAULT layout for all pages
    DocsLayout(
      header: Header(
        title: 'Jaspr Docs',
        logo: '/images/logo.svg',
        items: [
          ThemeToggle(),
          GitHubButton(repo: 'schultek/jaspr'),
        ],
      ),
      sidebar: Sidebar(
        groups: [
          SidebarGroup(links: [SidebarLink(text: "Overview", href: '/')]),
          SidebarGroup(title: 'Guides', links: [SidebarLink(text: "Quick Start", href: '/quick_start')]),
        ],
      ),
    ),
    BlogLayout(
      header: Header(
        title: 'Jaspr Blog',
        logo: '/images/logo.svg',
        items: [ThemeToggle()],
      ),
    ),
    EmptyLayout(),
  ],
)
```

### Custom Layouts (`PageLayoutBase`)

Extend `PageLayoutBase` to build custom layouts:

```dart
class MarketingLayout extends PageLayoutBase {
  const MarketingLayout();

  @override
  Pattern get name => 'marketing'; // Matched by `layout: marketing` in frontmatter

  @override
  Iterable<Component> buildHead(Page page) sync* {
    yield* super.buildHead(page); // Preserves standard title and meta tags
    yield link(rel: 'canonical', href: page.url);
  }

  @override
  Component buildBody(Page page, Component child) {
    return div(classes: 'marketing-shell', [
      SiteNavbar(),
      main_([child]),
      SiteFooter(),
    ]);
  }
}
```

#### Dos and Don'ts:
- **DO** put the most common layout first in `ContentApp(layouts: [...])`. It serves as the fallback when frontmatter omits `layout:`.
- **DO** call `yield* super.buildHead(page)` in custom layouts to ensure standard SEO meta tags (title, description, keywords) from frontmatter are emitted into `<head>`.
- **DO NOT** hardcode navigation links in markdown files; define them in `Sidebar` / `Header` components or load them via `_data/navigation.yaml`.

---

## 4. Built-in Markdown Components

`jaspr_content` includes built-in components that authors can embed directly into Markdown files.

### Component Reference & Import Rules

| Component | Import Path | Markdown Syntax / Usage |
|---|---|---|
| `Callout()` | `package:jaspr_content/components/callout.dart` | `<Info>...</Info>`, `<Warning>...</Warning>`, `<Error>...</Error>`, `<Success>...</Success>` |
| `CodeBlock()` | `package:jaspr_content/components/code_block.dart` | Automatic: overrides standard markdown fenced code blocks ` ```dart ` |
| `Tabs()` | `package:jaspr_content/components/tabs.dart` | `<Tabs defaultValue="dart"><TabItem label="Dart" value="dart">...</TabItem></Tabs>` |
| `FileTree()` | `package:jaspr_content/components/file_tree.dart` | `<FileTree>` wrapping a single unordered markdown list |
| `Image()` | `package:jaspr_content/components/image.dart` | `Image(zoom: true)`: enhances markdown `![alt](url)` with lightbox zoom & caption |
| `DropCap()` | `package:jaspr_content/components/drop_cap.dart` | `<DropCap />` at start of blog post |
| `PostBreak()` | `package:jaspr_content/components/post_break.dart` | `<PostBreak />` aesthetic article divider |

#### Dos and Don'ts:
- **DO** use capitalized tag names `<Info>`, `<Warning>`, `<Error>`, `<Success>` for callouts. The regex pattern strictly matches capitalized names.
- **DO** use `label="..."` on `<TabItem>` (NOT `name="..."`).
- **DO** place a single standard markdown unordered list (`- folder/`, `- file.dart`) inside `<FileTree>`.
- **DO NOT** attempt to import built-in components from `package:jaspr_content/jaspr_content.dart`. You MUST import each component from `package:jaspr_content/components/<name>.dart`.

---

## 5. Creating Custom Markdown Components

### Pattern 1: Tag-Matched Component (`CustomComponent`)

Wrap any Jaspr component so authors can use `<MyTag>` in markdown:

```dart
// 1. In lib/main.server.dart:
ContentApp(
  components: [
    CustomComponent(
      pattern: 'Card',
      builder: (name, attributes, child) {
        return div(classes: 'card ${attributes['variant'] ?? 'default'}', [
          if (attributes['title'] case final title?) h3([.text(title)]),
          child ?? .empty(),
        ]);
      },
    ),
  ],
)
```

In markdown:
```markdown
<Card title="Quick Tip" variant="highlight">
  This is inner **markdown** passed as `child`.
</Card>
```

### Pattern 2: Interactive Islands (`@client` inside Markdown)

When a component embedded in markdown requires client-side state or event listeners:

```dart
// lib/components/counter.dart
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

@client
class Counter extends StatefulComponent {
  const Counter({this.initial = 0, super.key});
  final int initial;

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  late int count = component.initial;

  @override
  Component build(BuildContext context) {
    return button(
      onClick: () => setState(() => count++),
      [.text('Count: $count')],
    );
  }
}
```

Register in `main.server.dart`:

```dart
ContentApp(
  components: [
    CustomComponent(
      pattern: 'Counter',
      builder: (name, attributes, _) {
        final initial = int.tryParse(attributes['initial'] ?? '') ?? 0;
        return Counter(initial: initial);
      },
    ),
  ],
)
```

Now `<Counter initial="5" />` in markdown hydrates into an interactive client island in the browser!

### Pattern 3: Overriding Standard Markdown Nodes (`CustomComponentBase`)

To intercept standard markdown elements (like `blockquote` or `a`):

```dart
class BlockquoteOverride extends CustomComponentBase {
  const BlockquoteOverride();

  @override
  Pattern get pattern => 'blockquote';

  @override
  Component apply(String name, Map<String, String> attributes, Component? child) {
    return div(classes: 'custom-quote', [
      span(classes: 'quote-icon', [.text('“')]),
      child ?? .empty(),
    ]);
  }
}
```

#### Dos and Don'ts:
- **DO** handle `child ?? .empty()` in `CustomComponent` builders to gracefully support self-closing tags (e.g. `<MyComponent />`).
- **DO** annotate custom interactive components with `@client`. Static content around them remains zero-JS HTML.
- **DO NOT** instantiate stateful client logic directly inside the server `builder` callback; instantiate the `@client` component and pass attributes as props.

---

## 6. Theming & Theme Tokens

### Setting up `ContentTheme`

Import from `package:jaspr_content/theme.dart`:

```dart
import 'package:jaspr_content/theme.dart';

ContentTheme(
  // Brand colors with light/dark variants
  primary: ThemeColor(Color('#01589B'), dark: Color('#41C3FE')),
  background: ThemeColor(Colors.white, dark: Color('#0b0d0e')),
  text: ThemeColor(ThemeColors.gray.$800, dark: ThemeColors.gray.$100),

  // Typography
  font: FontFamilies.arial,
  codeFont: FontFamily('FiraCode'),

  // Override built-in content colors
  colors: [
    ContentColors.quoteBorders.apply(ThemeColors.blue.$400),
    ContentColors.preBg.apply(ThemeColor(ThemeColors.slate.$100, dark: ThemeColors.slate.$800)),
  ],
)
```

### Custom `ColorToken`s

Create custom semantic tokens that automatically adapt to light/dark themes:

```dart
// 1. Define token
final brandAccent = ColorToken(
  'brand-accent', // Emits CSS variable `--brand-accent`
  ThemeColors.indigo.$600,
  dark: ThemeColors.indigo.$400,
);

// 2. Register in ContentTheme
ContentTheme(
  colors: [brandAccent],
)

// 3. Use directly in Jaspr CSS rules (ColorToken implements Color)
@css
static List<StyleRule> get styles => [
  css('.featured-pill').styles(
    backgroundColor: brandAccent,
    color: ContentColors.background,
    border: .all(color: ContentColors.quoteBorders),
  ),
];
```

### Opting Out of Prose Typography: `not-content`

To embed custom HTML or marketing widgets without prose styling (margins, line-heights, heading scale):

```html
<div class="not-content custom-widget">
  <h3>Raw Widget</h3>
</div>
```

#### Dos and Don'ts:
- **DO** pass `ColorToken` instances directly to style properties (`backgroundColor`, `color`, `border: .all(color: ...)`). Because `ColorToken` implements `Color`, no manual `Color.variable(...)` string wrapper is needed.
- **DO** use `ThemeColor(light, dark: dark)` for automatic dark mode handling.
- **DO** apply `class="not-content"` to isolate custom UI cards, grids, or embeds from global markdown prose rules.
- **DO NOT** hardcode raw hex values in individual component styles when semantic tokens exist.

---

## 7. Templating & Data Loading

### Templating Engines (`TemplateEngine`)

Enable templating to evaluate variables and conditionals in markdown before parsing:

```dart
ContentApp(
  templateEngine: MustacheTemplateEngine(), // or LiquidTemplateEngine()
)
```

In markdown:
```markdown
# {{ page.title }}

{{#page.showWarning}}
<Warning>This page is a draft.</Warning>
{{/page.showWarning}}
```

### Structured Data (`content/_data/`)

Store site-wide structured data in `.yaml` or `.json` files inside `content/_data/`:

```yaml title="content/_data/site.yaml"
title: "Jaspr Documentation"
supportEmail: "support@example.com"
```

Access in templates via `{{ site.property }}`:
```markdown
For help, contact [{{ site.supportEmail }}](mailto:{{ site.supportEmail }}).
```

Access in Dart components via `context.page.data.site['supportEmail']`.

### Eager Loading Requirement

When a page or template depends on other pages (e.g. blog archive, site search index, RSS feed):

```dart
ContentApp(
  eagerlyLoadAllPages: true, // Loads all pages at startup instead of lazily on request
)
```

In a Jaspr component:
```dart
class BlogIndex extends StatelessComponent {
  const BlogIndex({super.key});

  @override
  Component build(BuildContext context) {
    // context.pages returns all loaded pages when eagerlyLoadAllPages: true
    final posts = context.pages
        .where((p) => p.url.startsWith('/blog/') && p.url != '/blog/')
        .toList();

    return ul([
      for (final post in posts)
        li([
          a(href: post.url, [
            .text(post.data.page['title'] as String? ?? post.url),
          ]),
        ]),
    ]);
  }
}
```

#### Dos and Don'ts:
- **DO** set `eagerlyLoadAllPages: true` whenever templates reference `pages` or when generating global feeds.
- **DO NOT** access `context.pages` in lazy mode (`eagerlyLoadAllPages: false`), as only previously visited pages will be loaded.
- **DO** keep global metadata in `content/_data/` instead of duplicating it across frontmatter headers.
