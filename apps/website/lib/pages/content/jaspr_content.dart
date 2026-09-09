import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../components/code_window/code_window.dart';
import '../../components/gradient_border.dart';
import '../../components/icon.dart';
import '../../components/link_button.dart';
import '../../constants/theme.dart';

class JasprContent extends StatelessComponent {
  const JasprContent({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'content-page', [
          // Hero Section
          div(classes: 'cp-hero', [
            span(classes: 'caption2 text-gradient', [.text('STATIC SITES & DOCUMENTATION')]),
            h1([
              .text('The '),
              span(classes: 'text-gradient', [.text('VitePress & Astro')]),
              .text(' for Dart'),
            ]),
            p(classes: 'cp-subtitle', [
              .text(
                'Build lightning-fast documentation hubs, blogs, and content websites. '
                'Combine the simplicity of Markdown with the power of interactive Dart components — '
                'proven at scale on over 3,900 pages of Flutter & Dart documentation.',
              ),
            ]),
            div(classes: 'cp-actions', [
              LinkButton.filled(
                label: 'Read the Documentation',
                icon: 'book-open',
                to: 'https://docs.jaspr.site',
                target: .blank,
              ),
              LinkButton.outlined(
                label: 'View on pub.dev',
                icon: 'external-link',
                to: 'https://pub.dev/packages/jaspr_content',
                target: .blank,
              ),
              LinkButton.outlined(
                label: 'See Google Case Study',
                icon: 'arrow-right',
                to: '/case-studies/flutter-dart',
              ),
            ]),
          ]),

          // Features Grid
          div(classes: 'cp-section', [
            div(classes: 'cp-section-header', [
              span(classes: 'caption text-gradient', [.text('Features')]),
              h2([.text('Everything You Need for Content Sites')]),
              p([.text('From simple blogs to enterprise-scale documentation portals.')]),
            ]),
            div(classes: 'cp-features-grid', [
              div(classes: 'cp-feature-card', [
                div(classes: 'cp-icon', [Icon('file-text')]),
                h4([.text('Markdown & YAML Frontmatter')]),
                p([
                  .text(
                    'Author content in standard Markdown with structured YAML frontmatter for metadata, SEO tags, authors, and layout options.',
                  ),
                ]),
              ]),
              div(classes: 'cp-feature-card', [
                div(classes: 'cp-icon', [Icon('code')]),
                h4([.text('Embedded Dart Components')]),
                p([
                  .text(
                    'Embed live, interactive Jaspr components directly into Markdown documents. Perfect for interactive code demos, tabs, and alerts.',
                  ),
                ]),
              ]),
              div(classes: 'cp-feature-card', [
                div(classes: 'cp-icon', [Icon('sparkles')]),
                h4([.text('Blazing Static Generation')]),
                p([
                  .text(
                    'Pre-render thousands of pages at build time. Enjoy zero JavaScript payloads by default, with client-side hydration only where needed.',
                  ),
                ]),
              ]),
              div(classes: 'cp-feature-card', [
                div(classes: 'cp-icon', [Icon('layers')]),
                h4([.text('Customizable Layouts & Themes')]),
                p([
                  .text(
                    'Build headers, footers, sidebars, and custom layouts in pure, type-safe Dart. No clunky template systems or proprietary DSLs.',
                  ),
                ]),
              ]),
              div(classes: 'cp-feature-card', [
                div(classes: 'cp-icon', [Icon('trophy')]),
                h4([.text('Built-in SEO & Social Graph')]),
                p([
                  .text(
                    'Automatic OpenGraph tags, Twitter cards, meta descriptions, and clean URL routing out of the box for maximum organic visibility.',
                  ),
                ]),
              ]),
              div(classes: 'cp-feature-card', [
                div(classes: 'cp-icon', [Icon('cpu')]),
                h4([.text('Syntax Highlighting')]),
                p([
                  .text(
                    'First-class syntax highlighting for Dart, HTML, CSS, JavaScript, YAML, JSON, and dozens of other programming languages.',
                  ),
                ]),
              ]),
            ]),
          ]),

          // Code Window Section
          div(classes: 'cp-section cp-code-section', [
            div(classes: 'cp-section-header', [
              span(classes: 'caption text-gradient', [.text('Simplicity by Design')]),
              h2([.text('Write Markdown, Build with Dart')]),
              p([.text('Organize your content directory and let jaspr_content handle parsing, routing, and rendering.')]),
            ]),
            div(classes: 'cp-code-preview', [
              CodeWindow(
                name: 'content/getting-started.md',
                inactiveName: 'lib/main.server.dart',
                language: 'markdown',
                source: '''
---
title: Getting Started with Jaspr
description: Learn how to build your first website in Dart.
layout: docs
---

# Welcome to Jaspr

Jaspr brings the **productivity of Flutter** to the web!

<Counter initialCount={5} />

```dart
void main() {
  runApp(App());
}
```
''',
              ),
            ]),
          ]),

          // Getting Started Callout
          div(classes: 'cp-cta-box', [
            GradientBorder(
              radius: 16,
              child: div(classes: 'cp-cta-inner', [
                span(classes: 'caption2 text-gradient', [.text('GET STARTED TODAY')]),
                h3([.text('Start Building with jaspr_content')]),
                p([
                  .text(
                    'Add jaspr_content to your project or explore the documentation to build your next documentation hub or blog in Dart.',
                  ),
                ]),
                div(classes: 'code-install-box', [
                  code([.text('dart pub add jaspr_content')]),
                ]),
                div(classes: 'cp-cta-actions', [
                  LinkButton.filled(
                    label: 'Read Documentation',
                    icon: 'book-open',
                    to: 'https://docs.jaspr.site',
                    target: .blank,
                  ),
                  LinkButton.outlined(
                    label: 'Need Consulting? Talk to Kilian',
                    icon: 'arrow-right',
                    to: '/consulting',
                  ),
                ]),
              ]),
            ),
          ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.content-page', [
      css('&').styles(
        display: .flex,
        flexDirection: .column,
        alignItems: .center,
        padding: .only(top: 8.rem, bottom: 6.rem),
        boxSizing: .borderBox,
      ),
      css('.cp-hero', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          alignItems: .center,
          textAlign: .center,
          maxWidth: 50.rem,
          padding: .symmetric(horizontal: contentPadding),
          margin: .only(bottom: 4.5.rem),
          boxSizing: .borderBox,
        ),
        css('h1').styles(
          fontSize: 3.2.rem,
          fontWeight: .w800,
          lineHeight: 1.15.em,
          margin: .only(top: 0.5.rem, bottom: 1.2.rem),
          raw: {'text-wrap': 'balance'},
        ),
        css('.cp-subtitle').styles(
          fontSize: 1.2.rem,
          color: textDark,
          lineHeight: 1.6.em,
          margin: .only(bottom: 2.2.rem),
          raw: {'text-wrap': 'balance'},
        ),
        css('.cp-actions').styles(
          display: .flex,
          flexWrap: .wrap,
          gap: .all(1.rem),
          justifyContent: .center,
        ),
      ]),
      css('.cp-section', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          alignItems: .center,
          maxWidth: maxContentWidth,
          padding: .symmetric(horizontal: contentPadding),
          margin: .only(bottom: 5.rem),
          boxSizing: .borderBox,
          width: 100.percent,
        ),
      ]),
      css('.cp-section-header', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          alignItems: .center,
          textAlign: .center,
          margin: .only(bottom: 3.rem),
        ),
        css('h2').styles(
          fontSize: 2.3.rem,
          fontWeight: .w700,
          margin: .only(top: 0.4.rem, bottom: 0.6.rem),
        ),
        css('p').styles(
          fontSize: 1.05.rem,
          color: textDim,
          margin: .zero,
        ),
      ]),
      css('.cp-features-grid', [
        css('&').styles(
          display: .grid,
          width: 100.percent,
          gap: .all(1.5.rem),
          raw: {'grid-template-columns': 'repeat(auto-fit, minmax(280px, 1fr))'},
        ),
      ]),
      css('.cp-feature-card', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          padding: .all(2.rem),
          backgroundColor: surface,
          border: .all(color: borderColor, width: 1.px),
          radius: .circular(12.px),
          height: 100.percent,
          boxSizing: .borderBox,
          transition: .new('all', duration: 200.ms, curve: .easeInOut),
        ),
        css('&:hover').styles(
          border: .all(color: borderColor2, width: 1.px),
          transform: .translate(y: (-2).px),
          shadow: BoxShadow(
            offsetX: 0.px,
            offsetY: 4.px,
            blur: 12.px,
            color: Color.rgba(0, 0, 0, 0.05),
          ),
        ),
        css('.cp-icon').styles(
          fontSize: 1.5.rem,
          color: primaryMid,
          margin: .only(bottom: 1.rem),
        ),
        css('h4').styles(
          fontSize: 1.15.rem,
          fontWeight: .w600,
          color: textBlack,
          margin: .only(top: .zero, bottom: 0.5.rem),
        ),
        css('p').styles(
          fontSize: 0.95.rem,
          color: textDark,
          lineHeight: 1.5.em,
          margin: .zero,
        ),
      ]),
      css('.cp-code-section', [
        css('&').styles(alignItems: .center),
        css('.cp-code-preview').styles(
          width: 100.percent,
          maxWidth: 42.rem,
        ),
      ]),
      css('.cp-cta-box', [
        css('&').styles(
          width: 100.percent,
          maxWidth: 46.rem,
          padding: .symmetric(horizontal: contentPadding),
          boxSizing: .borderBox,
        ),
        css('.cp-cta-inner').styles(
          display: .flex,
          flexDirection: .column,
          padding: .all(2.8.rem),
          backgroundColor: surface,
          radius: .circular(16.px),
          textAlign: .center,
          alignItems: .center,
        ),
        css('h3').styles(
          fontSize: 2.rem,
          fontWeight: .w700,
          margin: .only(top: 0.5.rem, bottom: 0.8.rem),
        ),
        css('p').styles(
          maxWidth: 36.rem,
          fontSize: 1.05.rem,
          color: textDark,
          lineHeight: 1.6.em,
          margin: .only(bottom: 1.5.rem),
        ),
        css('.code-install-box', [
          css('&').styles(
            padding: .symmetric(horizontal: 1.2.rem, vertical: 0.7.rem),
            radius: .circular(8.px),
            border: .all(color: borderColor, width: 1.px),
            backgroundColor: surfaceLow,
            margin: .only(bottom: 1.8.rem),
          ),
          css('code').styles(
            fontSize: 0.95.rem,
            color: textBlack,
            fontWeight: .w600,
          ),
        ]),
        css('.cp-cta-actions').styles(
          display: .flex,
          flexWrap: .wrap,
          gap: .all(1.rem),
          justifyContent: .center,
        ),
      ]),
    ]),
    css.media(.screen(maxWidth: 750.px), [
      css('.content-page .cp-hero h1').styles(fontSize: 2.2.rem),
      css('.content-page .cp-hero .cp-subtitle').styles(fontSize: 1.05.rem),
      css('.content-page .cp-section-header h2').styles(fontSize: 1.7.rem),
      css('.content-page .cp-cta-box .cp-cta-inner').styles(padding: .all(1.6.rem)),
    ]),
  ];
}
