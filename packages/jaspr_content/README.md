![Banner](https://raw.githubusercontent.com/schultek/jaspr/main/assets/content/banner.png)

<p align="center">
  <a href="https://pub.dev/packages/jaspr_content"><img src="https://img.shields.io/pub/v/jaspr_content?label=pub.dev&labelColor=333940&logo=dart&color=00589B" alt="pub"></a>
  <a href="https://github.com/schultek/jaspr"><img src="https://img.shields.io/github/stars/schultek/jaspr?style=flat&label=stars&labelColor=333940&color=8957e5&logo=github" alt="github"></a>
  <a href="https://discord.gg/XGXrGEk4c6"><img src="https://img.shields.io/discord/993167615587520602?logo=discord&logoColor=fff&labelColor=333940" alt="discord"></a>
</p>

<p align="center">
  <a href="https://docs.jaspr.site/content/quick_start">Quickstart</a> •
  <a href="https://docs.jaspr.site/content">Documentation</a>
</p>

# Jaspr Content

A package for building **content-driven sites** like documentation, blogs or marketing pages with [Jaspr](https://pub.dev/packages/jaspr).

It provides **out-of-the-box tools** for loading, parsing, and rendering content from various sources like markdown files. It is **fully customizable** and you are able to add your **own implementations** for each part.

> Looking to get started? Head to the [Quickstart](https://docs.jaspr.site/content/quick_start) guide.

## Features

- **📖 Markdown**: Load and parse markdown files from your filesystem or a remote source (e.g. Github).

- **🗃️ Frontmatter**: Parse frontmatter data from markdown files and use it in your components.

- **🖋️ Templating**: Use a templating language like [mustache](https://mustache.github.io/mustache.5.html) to inject data into your content.

- **🧩 Components**: Enhance your content with  Jaspr components like [`<Info>`](https://docs.jaspr.site/content/components/callout) or [`<Tabs>`](https://docs.jaspr.site/content/components/tabs). Choose from the built-in components or add your own.

- **📐 Layouts**: Use pre-defined layouts like the [DocsLayout](https://docs.jaspr.site/content/layouts/docs_layout) or create your own.

- **🎨 Theming**: Use the built-in [theming system](https://docs.jaspr.site/content/concepts/theming) to customize the look and feel of your site. With light and dark mode out of the box.

> `jaspr_content` is fully compatible with "normal" Jaspr. You can use components and pages you already have in your app and mix them with content from `jaspr_content`.

## Documentation

Checkout the official documentation at [docs.jaspr.site/content](https://docs.jaspr.site/content). The docs are split into:

- [**Quickstart**](https://docs.jaspr.site/content/quick_start): A quick introduction to get you started with `jaspr_content`.
- [**Guides**](https://docs.jaspr.site/content/guides/adding_pages): Step-by-step guides for common use-cases and features.
- [**Concepts**](https://docs.jaspr.site/content/concepts/pages): In-depth explanations of the core concepts and features of `jaspr_content`.
- [**Components**](https://docs.jaspr.site/content/components/callout): 
  A list of all built-in components and their usage.
- [**Extensions**](https://docs.jaspr.site/content/extensions/heading_anchors): A list of all built-in extensions and their usage.
- [**Layouts**](https://docs.jaspr.site/content/layouts/docs_layout): A list of all built-in layouts and their usage.

