import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../components/gradient_border.dart';
import '../../components/link_button.dart';
import '../../constants/theme.dart';

class CaseStudy extends StatelessComponent {
  const CaseStudy({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'case-study-page', [
          // Hero Section
          div(classes: 'cs-hero', [
            div(classes: 'cs-badge-row', [
              span(classes: 'caption2 text-gradient', [.text('FLAGSHIP CASE STUDY')]),
              span(classes: 'cs-pill', [.text('Google • Flutter & Dart')]),
            ]),
            h1([
              .text('Serving Millions of Developers: How Google Rebuilt Flutter & Dart’s Web Presence with '),
              span(classes: 'text-gradient', [.text('Jaspr')]),
            ]),
            p(classes: 'cs-subtitle', [
              .text(
                'Over 3,900 documentation pages migrated from fragmented static site generators '
                'to a unified, high-performance Dart stack powered by Jaspr and jaspr_content.',
              ),
            ]),
            div(classes: 'cs-links-row', [
              LinkButton.filled(
                label: 'Flutter Team Blog Post',
                icon: 'external-link',
                to: 'https://flutter.dev/blog/we-rebuilt-flutters-websites-with-dart-and-jaspr',
                target: .blank,
              ),
              LinkButton.outlined(
                label: 'Google Open Source Blog',
                icon: 'external-link',
                to: 'https://opensource.googleblog.com/2026/04/jaspr-why-web-development-in-dart-might-just-be-a-good-idea.html',
                target: .blank,
              ),
              LinkButton.outlined(
                label: 'flutter/website on GitHub',
                icon: 'external-link',
                to: 'https://github.com/flutter/website',
                target: .blank,
              ),
            ]),
          ]),

          // Metrics Banner
          div(classes: 'cs-metrics-section', [
            div(classes: 'cs-metric-card', [
              div(classes: 'metric-number text-gradient', [.text('1M+')]),
              div(classes: 'metric-title', [.text('Monthly Active Developers')]),
              p([.text('Developers worldwide rely on the official Flutter and Dart documentation daily.')]),
            ]),
            div(classes: 'cs-metric-card', [
              div(classes: 'metric-number text-gradient', [.text('3,900+')]),
              div(classes: 'metric-title', [.text('Documentation Pages')]),
              p([.text('Statically compiled with blazing performance, high SEO scores, and instant loads.')]),
            ]),
            div(classes: 'cs-metric-card', [
              div(classes: 'metric-number text-gradient', [.text('100%')]),
              div(classes: 'metric-title', [.text('Pure Dart Tech Stack')]),
              p([.text('Eliminated fragmented Jekyll/Python tools in favor of unified Dart tooling.')]),
            ]),
            div(classes: 'cs-metric-card', [
              div(classes: 'metric-number text-gradient', [.text('Live')]),
              div(classes: 'metric-title', [.text('Interactive Code Tutorials')]),
              p([.text('Directly embedded interactive learning experiences on dart.dev/learn and flutter.dev.')]),
            ]),
          ]),

          // Narrative Content
          div(classes: 'cs-narrative', [
            section(classes: 'cs-chapter', [
              h2([.text('The Challenge: Fragmented Tooling at Massive Scale')]),
              p([
                .text(
                  'The official websites for Flutter and Dart (flutter.dev, dart.dev, and docs.flutter.dev) '
                  'constitute one of the largest and most heavily frequented developer portals in the world. '
                  'Historically, the sites were built with a mix of legacy static site generators written in '
                  'Ruby (Jekyll), Python, and disparate JavaScript build steps.',
                ),
              ]),
              p([
                .text(
                  'For a team composed of world-class Dart and Flutter engineers, this multi-language architecture '
                  'created substantial friction. Every documentation update or feature enhancement meant switching '
                  'between programming languages, managing mismatched toolchains, and maintaining custom glue code. '
                  'Furthermore, embedding interactive code playgrounds and live tutorials was cumbersome and fragile.',
                ),
              ]),
            ]),

            section(classes: 'cs-chapter', [
              h2([.text('The Solution: Jaspr & jaspr_content')]),
              p([
                .text(
                  'To solve this, Google partnered with Kilian Schulte, the creator of Jaspr, to migrate '
                  'the entire web presence to Jaspr and jaspr_content. This unified the entire codebase '
                  'under a single language: Dart.',
                ),
              ]),
              div(classes: 'cs-feature-box', [
                div(classes: 'feature-box-inner', [
                  h4([.text('Key Technical Pillars of the Migration')]),
                  ul([
                    li([
                      strong([.text('Static Site Generation (SSG): ')]),
                      .text('Zero-overhead HTML pre-rendering ensures optimal search engine indexing (SEO) and instant page load speeds.'),
                    ]),
                    li([
                      strong([.text('jaspr_content Engine: ')]),
                      .text('Engineered specifically for large-scale documentation, handling over 3,900 Markdown files with ease.'),
                    ]),
                    li([
                      strong([.text('Embedded Interactive Tutorials: ')]),
                      .text('Jaspr components seamlessly integrate into Markdown, powering the new interactive learning guides at dart.dev/learn and docs.flutter.dev/learn.'),
                    ]),
                    li([
                      strong([.text('100% Code & Logic Sharing: ')]),
                      .text('Shared models, validation, and layout components without any cross-language translation overhead.'),
                    ]),
                  ]),
                ]),
              ]),
            ]),

            section(classes: 'cs-chapter', [
              h2([.text('The Outcome: Productivity & Production Reliability')]),
              p([
                .text(
                  'The migration was rolled out seamlessly to over a million monthly active developers. '
                  'Engineers working on Flutter can now contribute to documentation using the exact same '
                  'Dart tools, analyzer, formatter, and package ecosystem they use every day.',
                ),
              ]),
              blockquote(classes: 'cs-quote', [
                p([
                  .text(
                    '“Jaspr is an amazing usage of Dart’s web stack and a compliment to Flutter web. '
                    'It’s a great place to start if you want to use HTML and CSS with Dart.”',
                  ),
                ]),
                div(classes: 'cs-quote-author', [
                  strong([.text('Kevin Moore')]),
                  .text(' — Product Manager for Dart and Flutter at Google'),
                ]),
              ]),
            ]),

            // CTA Box for Consulting
            div(classes: 'cs-cta-box', [
              GradientBorder(
                radius: 16,
                child: div(classes: 'cs-cta-inner', [
                  span(classes: 'caption2 text-gradient', [.text('ENTERPRISE CONSULTING')]),
                  h3([.text('Planning a Flutter-to-Web Migration or High-Traffic Web Project?')]),
                  p([
                    .text(
                      'Work directly with Kilian Schulte, creator of Jaspr and lead on the Flutter/Dart website migration. '
                      'From architectural reviews to hands-on custom development, accelerate your web journey with expert guidance.',
                    ),
                  ]),
                  div(classes: 'cs-cta-actions', [
                    LinkButton.filled(
                      label: 'Explore Consulting & Services',
                      icon: 'arrow-right',
                      to: '/consulting',
                    ),
                    LinkButton.outlined(
                      label: 'Schedule a Call',
                      icon: 'send',
                      to: 'mailto:kilian@schultek.dev',
                    ),
                  ]),
                ]),
              ),
            ]),
          ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.case-study-page', [
      css('&').styles(
        display: .flex,
        flexDirection: .column,
        alignItems: .center,
        padding: .only(top: 8.rem, bottom: 6.rem),
        boxSizing: .borderBox,
      ),
      css('.cs-hero', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          alignItems: .center,
          textAlign: .center,
          maxWidth: 54.rem,
          padding: .symmetric(horizontal: contentPadding),
          margin: .only(bottom: 4.rem),
          boxSizing: .borderBox,
        ),
        css('.cs-badge-row').styles(
          display: .flex,
          alignItems: .center,
          gap: .column(0.8.rem),
          margin: .only(bottom: 1.rem),
        ),
        css('.cs-pill').styles(
          padding: .symmetric(horizontal: 0.75.rem, vertical: 0.25.rem),
          radius: .circular(20.px),
          fontSize: 0.8.rem,
          fontWeight: .w600,
          color: textDark,
          border: .all(color: borderColor2, width: 1.px),
          backgroundColor: surfaceLow,
        ),
        css('h1').styles(
          fontSize: 3.2.rem,
          fontWeight: .w800,
          lineHeight: 1.15.em,
          margin: .only(bottom: 1.2.rem),
          raw: {'text-wrap': 'balance'},
        ),
        css('.cs-subtitle').styles(
          fontSize: 1.25.rem,
          color: textDark,
          lineHeight: 1.6.em,
          margin: .only(bottom: 2.2.rem),
          raw: {'text-wrap': 'balance'},
        ),
        css('.cs-links-row').styles(
          display: .flex,
          flexWrap: .wrap,
          gap: .all(1.rem),
          justifyContent: .center,
        ),
      ]),
      css('.cs-metrics-section', [
        css('&').styles(
          display: .grid,
          width: 100.percent,
          maxWidth: maxContentWidth,
          padding: .symmetric(horizontal: contentPadding),
          margin: .only(bottom: 5.rem),
          gap: .all(1.5.rem),
          boxSizing: .borderBox,
          raw: {'grid-template-columns': 'repeat(auto-fit, minmax(220px, 1fr))'},
        ),
      ]),
      css('.cs-metric-card', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          padding: .all(2.rem),
          radius: .circular(14.px),
          border: .all(color: borderColor, width: 1.px),
          backgroundColor: surface,
          textAlign: .center,
          alignItems: .center,
        ),
        css('.metric-number').styles(
          fontSize: 2.8.rem,
          fontWeight: .w800,
          lineHeight: 1.1.em,
          margin: .only(bottom: 0.4.rem),
        ),
        css('.metric-title').styles(
          fontSize: 1.05.rem,
          fontWeight: .w600,
          color: textBlack,
          margin: .only(bottom: 0.6.rem),
        ),
        css('p').styles(
          fontSize: 0.88.rem,
          color: textDim,
          lineHeight: 1.45.em,
          margin: .zero,
        ),
      ]),
      css('.cs-narrative', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          maxWidth: 48.rem,
          padding: .symmetric(horizontal: contentPadding),
          boxSizing: .borderBox,
          gap: .row(3.5.rem),
        ),
        css('.cs-chapter h2').styles(
          fontSize: 2.rem,
          fontWeight: .w700,
          color: textBlack,
          margin: .only(bottom: 1.2.rem),
        ),
        css('.cs-chapter p').styles(
          fontSize: 1.1.rem,
          lineHeight: 1.7.em,
          color: textDark,
          margin: .only(bottom: 1.2.rem),
        ),
      ]),
      css('.cs-feature-box', [
        css('&').styles(margin: .symmetric(vertical: 2.rem)),
        css('.feature-box-inner').styles(
          padding: .all(2.rem),
          backgroundColor: surface,
          border: .all(color: borderColor, width: 1.px),
          radius: .circular(12.px),
        ),
        css('h4').styles(
          fontSize: 1.2.rem,
          fontWeight: .w600,
          color: textBlack,
          margin: .only(top: .zero, bottom: 1.rem),
        ),
        css('ul').styles(
          padding: .only(left: 1.5.rem),
          margin: .zero,
          fontSize: 1.02.rem,
          lineHeight: 1.8.em,
          color: textDark,
        ),
        css('li').styles(margin: .only(bottom: 0.6.rem)),
      ]),
      css('.cs-quote', [
        css('&').styles(
          padding: .all(2.rem),
          margin: .symmetric(vertical: 2.5.rem),
          border: .only(left: .new(color: primaryMid, width: 4.px)),
          backgroundColor: surfaceLow,
          radius: .circular(8.px),
        ),
        css('p').styles(
          fontSize: 1.2.rem,
          fontStyle: .italic,
          lineHeight: 1.6.em,
          color: textBlack,
          margin: .only(bottom: 1.rem),
        ),
        css('.cs-quote-author').styles(
          fontSize: 0.95.rem,
          color: textDim,
          fontStyle: .normal,
        ),
      ]),
      css('.cs-cta-box', [
        css('&').styles(margin: .only(top: 2.rem)),
        css('.cs-cta-inner').styles(
          display: .flex,
          flexDirection: .column,
          padding: .all(2.5.rem),
          backgroundColor: surface,
          radius: .circular(16.px),
          textAlign: .center,
          alignItems: .center,
        ),
        css('h3').styles(
          fontSize: 1.8.rem,
          fontWeight: .w700,
          margin: .only(top: 0.5.rem, bottom: 0.8.rem),
          raw: {'text-wrap': 'balance'},
        ),
        css('p').styles(
          maxWidth: 38.rem,
          fontSize: 1.05.rem,
          color: textDark,
          lineHeight: 1.6.em,
          margin: .only(bottom: 2.rem),
          raw: {'text-wrap': 'balance'},
        ),
        css('.cs-cta-actions').styles(
          display: .flex,
          flexWrap: .wrap,
          gap: .all(1.rem),
          justifyContent: .center,
        ),
      ]),
    ]),
    css.media(.screen(maxWidth: 750.px), [
      css('.case-study-page .cs-hero h1').styles(fontSize: 2.2.rem),
      css('.case-study-page .cs-hero .cs-subtitle').styles(fontSize: 1.1.rem),
      css('.case-study-page .cs-narrative .cs-chapter h2').styles(fontSize: 1.6.rem),
      css('.case-study-page .cs-cta-box h3').styles(fontSize: 1.4.rem),
    ]),
  ];
}
