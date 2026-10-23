---
title: Register Custom Components in ContentApp for Rich Embedded Content
impact: MEDIUM-HIGH
impactDescription: Allows embedding interactive client widgets and rich callouts directly inside Markdown content
tags: content, markdown, components, jaspr_content
---

## Register Custom Components in ContentApp for Rich Embedded Content

**Impact: MEDIUM-HIGH (Allows embedding interactive client widgets and rich callouts directly inside Markdown content)**

`jaspr_content` enables authoring rich content sites where Markdown files can include custom HTML-like tags (e.g. `<Warning>`, `<Tabs>`, `<Demo>`).

Instead of writing fragile raw HTML snippets or scripts inside Markdown files, register components using `ContentApp(components: [...])`. You can use built-in components (such as `Callout()`, `Tabs()`, `FileTree()`), or create custom components by constructing a `CustomComponent` or extending `CustomComponentBase`. This enables:
- Seamless embedding of interactive `@client` islands inside static Markdown documentation.
- Consistent styling and layout across all content pages.
- Access to parsed tag attributes as strongly typed component parameters.

**Incorrect (raw HTML or script embeds inside markdown):**

```markdown
<!-- Fragile, untyped, and unmaintainable across documentation pages: -->
<div class="custom-callout-warning" style="border-left: 4px solid orange; padding: 10px;">
  <strong>Warning:</strong> Be careful with this configuration!
</div>
```

**Correct (defining and registering custom components in ContentApp):**

```dart
// lib/main.server.dart
import 'package:jaspr/server.dart';
import 'package:jaspr_content/components/callout.dart';
import 'package:jaspr_content/components/tabs.dart';
import 'package:jaspr_content/jaspr_content.dart';

import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(ContentApp(
    parsers: [
      MarkdownParser(),
    ],
    components: [
      // 1. Built-in components:
      Callout(),
      Tabs(),

      // 2. Custom components via CustomComponent factory:
      CustomComponent(
        pattern: 'Demo',
        builder: (name, attributes, child) => DemoWidget(
          title: attributes['title'] ?? 'Live Demo',
          child: child,
        ),
      ),
    ],
  ));
}
```

In your Markdown (`content/guide.md`):

```markdown
# Configuration Guide

<Warning>
  Be careful with this configuration!
</Warning>

<Demo title="Interactive Preview">
  Check out this demo component embedded directly in markdown.
</Demo>
```
