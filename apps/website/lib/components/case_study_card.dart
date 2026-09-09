import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../constants/theme.dart';
import 'link_button.dart';

class CaseStudyCard extends StatelessComponent {
  const CaseStudyCard({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'case-study-featured-card', [
      div(classes: 'featured-card', [
        div(classes: 'featured-card-header', [
          div(classes: 'featured-badge', [
            span(classes: 'caption2 text-gradient', [.text('FEATURED CASE STUDY')]),
            span(classes: 'featured-tag', [.text('Google • Flutter & Dart')]),
          ]),
        ]),
        div(classes: 'featured-body', [
          div(classes: 'featured-text', [
            h2([
              .text('How Google Rebuilt Flutter & Dart’s Web Presence with Jaspr'),
            ]),
            p([
              .text(
                'Over 3,900 documentation pages serving more than 1,000,000 monthly developers '
                'were migrated to Jaspr and jaspr_content. Eliminating fragmented Jekyll and Python '
                'tooling in favor of a single unified Dart stack with embedded interactive learning.',
              ),
            ]),
            div(classes: 'featured-stats', [
              div(classes: 'stat', [
                span(classes: 'stat-num text-gradient', [.text('1M+')]),
                span(classes: 'stat-desc', [.text('Monthly Developers')]),
              ]),
              div(classes: 'stat', [
                span(classes: 'stat-num text-gradient', [.text('3,900+')]),
                span(classes: 'stat-desc', [.text('Pages Generated')]),
              ]),
              div(classes: 'stat', [
                span(classes: 'stat-num text-gradient', [.text('100%')]),
                span(classes: 'stat-desc', [.text('Pure Dart Stack')]),
              ]),
            ]),
            div(classes: 'featured-actions', [
              LinkButton.filled(
                label: 'Read Full Case Study',
                icon: 'arrow-right',
                to: '/case-studies/flutter-dart',
              ),
              LinkButton.outlined(
                label: 'Flutter Team Blog',
                icon: 'external-link',
                to: 'https://flutter.dev/blog/we-rebuilt-flutters-websites-with-dart-and-jaspr',
                target: .blank,
              ),
            ]),
          ]),
          div(classes: 'featured-preview', [
            div(classes: 'pages-stack', [
              div(classes: 'stack-item stack-blog', [
                img(
                  src: 'images/showcase/flutter_blog.png',
                  alt: 'flutter.dev/blog',
                  classes: 'stack-img',
                ),
              ]),
              div(classes: 'stack-item stack-dart', [
                img(
                  src: 'images/showcase/dart_dev.png',
                  alt: 'dart.dev',
                  classes: 'stack-img',
                ),
              ]),
              div(classes: 'stack-item stack-docs', [
                img(
                  src: 'images/showcase/flutter_docs.png',
                  alt: 'docs.flutter.dev',
                  classes: 'stack-img',
                ),
              ]),
              div(classes: 'stack-item stack-flutter', [
                img(
                  src: 'images/showcase/flutter_dev.png',
                  alt: 'flutter.dev',
                  classes: 'stack-img',
                ),
              ]),
            ]),
          ]),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.case-study-featured-card', [
      css('&').styles(
        width: 100.percent,
        boxSizing: .borderBox,
      ),
      css('.featured-card', [
        css('&').styles(
          padding: .all(2.5.rem),
          backgroundColor: surface,
          radius: .circular(16.px),
          border: .all(color: borderColor, width: 1.px),
          display: .flex,
          flexDirection: .column,
          boxSizing: .borderBox,
          transition: Transition('border-color', duration: Duration(milliseconds: 250)),
        ),
        css('&:hover', [
          css('&').styles(
            border: .all(color: borderColor2, width: 1.px),
          ),
          css('.stack-blog').styles(raw: {
            'transform': 'rotate(8deg) translate(14px, -10px) scale(0.94)',
            'opacity': '0.95',
          }),
          css('.stack-dart').styles(raw: {
            'transform': 'rotate(-7deg) translate(-14px, -6px) scale(0.97)',
            'opacity': '0.98',
          }),
          css('.stack-docs').styles(raw: {
            'transform': 'rotate(4.5deg) translate(12px, 8px) scale(0.99)',
          }),
          css('.stack-flutter').styles(raw: {
            'transform': 'rotate(-2deg) translate(-6px, 6px) scale(1.02)',
            'box-shadow': '0 20px 40px -4px rgba(0, 0, 0, 0.35)',
          }),
        ]),
      ]),
      css('.featured-badge').styles(
        display: .flex,
        alignItems: .center,
        gap: .column(0.8.rem),
        margin: .only(bottom: 1.2.rem),
      ),
      css('.featured-tag').styles(
        padding: .symmetric(horizontal: 0.7.rem, vertical: 0.2.rem),
        radius: .circular(16.px),
        fontSize: 0.78.rem,
        fontWeight: .w600,
        color: textDark,
        border: .all(color: borderColor2, width: 1.px),
        backgroundColor: surfaceLow,
      ),
      css('.featured-body', [
        css('&').styles(
          display: .flex,
          flexDirection: .row,
          gap: .column(2.5.rem),
          alignItems: .center,
        ),
        css('.featured-text').styles(
          flex: .new(grow: 1, shrink: 1, basis: 26.rem),
        ),
        css('.featured-text h2').styles(
          fontSize: 2.1.rem,
          fontWeight: .w700,
          margin: .only(top: .zero, bottom: 0.8.rem),
          raw: {'text-wrap': 'balance'},
        ),
        css('.featured-text p').styles(
          fontSize: 1.05.rem,
          color: textDark,
          lineHeight: 1.6.em,
          margin: .only(bottom: 1.5.rem),
        ),
        css('.featured-stats', [
          css('&').styles(
            display: .flex,
            gap: .column(2.rem),
            margin: .only(bottom: 1.8.rem),
          ),
          css('.stat').styles(display: .flex, flexDirection: .column),
          css('.stat-num').styles(fontSize: 1.8.rem, fontWeight: .w800),
          css('.stat-desc').styles(fontSize: 0.82.rem, color: textDim),
        ]),
        css('.featured-actions', [
          css('&').styles(
            display: .flex,
            flexWrap: .wrap,
            gap: .all(0.8.rem),
            alignItems: .center,
          ),
        ]),
        css('.featured-preview').styles(
          flex: .new(grow: 1, shrink: 1, basis: 23.rem),
          display: .flex,
          alignItems: .center,
          justifyContent: .center,
          alignSelf: .stretch,
          minWidth: 18.rem,
          boxSizing: .borderBox,
        ),
      ]),
      css('.pages-stack', [
        css('&').styles(
          position: .relative(),
          width: 100.percent,
          height: 100.percent,
          minHeight: 22.rem,
          boxSizing: .borderBox,
        ),
        css('.stack-item', [
          css('&').styles(
            position: .absolute(),
            width: 78.percent,
            radius: .circular(12.px),
            overflow: .hidden,
            border: .all(color: borderColor, width: 1.px),
            backgroundColor: surface,
            shadow: .new(offsetX: .zero, offsetY: 12.px, blur: 32.px, color: shadowColor2),
            raw: {
              'transition': 'transform 380ms cubic-bezier(0.16, 1, 0.3, 1), box-shadow 380ms ease, opacity 380ms ease',
            },
          ),
          css('.stack-img').styles(
            width: 100.percent,
            height: .auto,
            display: .block,
            raw: {'pointer-events': 'none'},
          ),
        ]),
        // Layer 1 (Back): Flutter Blog
        css('.stack-blog').styles(
          zIndex: .new(1),
          position: .absolute(top: 0.percent, right: .zero),
          raw: {
            'transform': 'rotate(5deg) scale(0.92)',
            'opacity': '0.88',
          },
        ),
        // Layer 2: Dart Dev
        css('.stack-dart').styles(
          zIndex: .new(2),
          position: .absolute(top: 15.percent, left: 0.5.rem),
          raw: {
            'transform': 'rotate(-4deg) scale(0.95)',
            'opacity': '0.94',
          },
        ),
        // Layer 3: Flutter Docs
        css('.stack-docs').styles(
          zIndex: .new(3),
          position: .absolute(top: 30.percent, right: 0.8.rem),
          raw: {
            'transform': 'rotate(2.5deg) scale(0.97)',
            'opacity': '0.98',
          },
        ),
        // Layer 4 (Front): Flutter Dev
        css('.stack-flutter').styles(
          zIndex: .new(4),
          position: .absolute(top: 45.percent, left: 0.8.rem),
          raw: {
            'transform': 'rotate(-1.5deg) scale(1)',
            'opacity': '1',
          },
        ),
      ]),
    ]),
    css.media(.screen(maxWidth: 820.px), [
      css('.case-study-featured-card .featured-card').styles(padding: .all(1.5.rem)),
      css('.case-study-featured-card .featured-body').styles(
        flexDirection: .column,
        gap: .row(2.rem),
      ),
      css('.case-study-featured-card .featured-text h2').styles(fontSize: 1.7.rem),
      css('.case-study-featured-card .featured-preview').styles(width: 100.percent),
      css('.case-study-featured-card .pages-stack').styles(height: 18.rem, minHeight: 18.rem),
      css('.case-study-featured-card .stack-item').styles(width: 82.percent),
    ]),
  ];
}
