import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../components/icon.dart';
import '../../../components/link_button.dart';
import '../../../constants/theme.dart';

class ContentTeaser extends StatelessComponent {
  const ContentTeaser({super.key});

  @override
  Component build(BuildContext context) {
    return section(id: 'content-teaser', [
      div(classes: 'content-teaser-container', [
        div(classes: 'content-featured-card', [
          div(classes: 'content-card-top', [
            div(classes: 'content-card-text', [
              div(classes: 'content-badge', [
                span(classes: 'caption2 text-gradient', [.text('STATIC SITES & DOCUMENTATION')]),
                span(classes: 'content-tag', [
                  img(src: 'images/jaspr_content_logo.svg', alt: 'jaspr_content', classes: 'content-tag-logo'),
                  span([.text('jaspr_content')]),
                ]),
              ]),
              h2([.text('Build content-driven sites with Jaspr Content')]),
              p(classes: 'content-card-desc', [
                .text(
                  'The engine powering over 3,900 pages of the official Flutter and Dart documentation. '
                  'Transform Markdown and Dart components into blazing-fast static sites with zero JavaScript overhead.',
                ),
              ]),
            ]),
            div(classes: 'content-logo-preview', [
              img(
                src: 'images/jaspr_content_logo.svg',
                alt: 'Jaspr Content Logo',
                classes: 'content-logo-img',
              ),
            ]),
          ]),
          div(classes: 'content-features-grid', [
            div(classes: 'content-feature-card', [
              div(classes: 'subcard-header', [
                div(classes: 'subcard-icon-box icon-md', [
                  Icon('file-text', size: 1.35.rem),
                ]),
                span(classes: 'subcard-badge mono', [.text('.md + YAML')]),
              ]),
              h4([.text('Markdown + Frontmatter')]),
              p([
                .text(
                  'Write documentation, blog posts, and articles in standard Markdown with flexible YAML frontmatter metadata.',
                ),
              ]),
            ]),
            div(classes: 'content-feature-card', [
              div(classes: 'subcard-header', [
                div(classes: 'subcard-icon-box icon-dart', [
                  Icon('code', size: 1.35.rem),
                ]),
                span(classes: 'subcard-badge mono', [.text('<jaspr />')]),
              ]),
              h4([.text('Interactive Dart Components')]),
              p([
                .text(
                  'Drop live Jaspr components and interactive widgets straight into Markdown without switching languages.',
                ),
              ]),
            ]),
            div(classes: 'content-feature-card', [
              div(classes: 'subcard-header', [
                div(classes: 'subcard-icon-box icon-static', [
                  Icon('zap', size: 1.35.rem),
                ]),
                span(classes: 'subcard-badge mono', [.text('0 kB JS')]),
              ]),
              h4([.text('Optimized Static Generation')]),
              p([
                .text(
                  'Compile multi-thousand page hubs to pure HTML and CSS with instant page loads and outstanding SEO.',
                ),
              ]),
            ]),
          ]),
          div(classes: 'content-card-action', [
            LinkButton.filled(
              label: 'Explore Jaspr Content',
              icon: 'arrow-right',
              to: '/jaspr-content',
            ),
          ]),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('#content-teaser', [
      css('&').styles(
        display: .flex,
        padding: .only(bottom: sectionPadding),
        justifyContent: .center,
        alignItems: .center,
        boxSizing: .borderBox,
      ),
      css('.content-teaser-container').styles(
        width: 100.percent,
        maxWidth: maxContentWidth,
        padding: .symmetric(horizontal: contentPadding),
        boxSizing: .borderBox,
      ),
      css('.content-featured-card', [
        css('&').styles(
          padding: .all(2.5.rem),
          backgroundColor: surface,
          radius: .circular(16.px),
          border: .all(color: borderColor, width: 1.px),
          display: .flex,
          flexDirection: .column,
          boxSizing: .borderBox,
          width: 100.percent,
          transition: Transition('border-color', duration: Duration(milliseconds: 250)),
        ),
        css('&:hover', [
          css('&').styles(
            border: .all(color: borderColor2, width: 1.px),
          ),
          css('.content-logo-img').styles(
            raw: {
              'transform': 'translateY(-6px) rotate(1.5deg) scale(1.03)',
              'filter': 'drop-shadow(0 20px 32px rgba(0, 102, 180, 0.28))',
            },
          ),
        ]),
      ]),
      css('.content-card-top', [
        css('&').styles(
          display: .flex,
          flexDirection: .row,
          justifyContent: .spaceBetween,
          alignItems: .center,
          gap: .column(2.5.rem),
          margin: .only(bottom: 2.2.rem),
        ),
      ]),
      css('.content-card-text', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          alignItems: .start,
          textAlign: .start,
          flex: .new(grow: 1, shrink: 1, basis: 28.rem),
        ),
        css('h2').styles(
          margin: .only(top: .zero, bottom: 0.8.rem),
          raw: {'text-wrap': 'balance'},
        ),
      ]),
      css('.content-badge').styles(
        display: .flex,
        alignItems: .center,
        gap: .column(0.8.rem),
        margin: .only(bottom: 1.rem),
      ),
      css('.content-tag', [
        css('&').styles(
          display: .inlineFlex,
          alignItems: .center,
          gap: .column(0.4.rem),
          padding: .symmetric(horizontal: 0.7.rem, vertical: 0.2.rem),
          radius: .circular(16.px),
          fontSize: 0.78.rem,
          fontWeight: .w600,
          color: textDark,
          border: .all(color: borderColor2, width: 1.px),
          backgroundColor: surfaceLow,
        ),
      ]),
      css('.content-tag-logo').styles(
        width: 14.px,
        height: 14.px,
        raw: {'object-fit': 'contain'},
      ),
      css('.content-card-desc').styles(
        maxWidth: 48.rem,
        margin: .zero,
        color: textDark,
        fontSize: 1.05.rem,
        lineHeight: 1.6.em,
        raw: {'text-wrap': 'balance'},
      ),
      css('.content-logo-preview', [
        css('&').styles(
          display: .flex,
          alignItems: .center,
          justifyContent: .center,
          flex: .new(grow: 0, shrink: 0, basis: 14.rem),
          padding: .symmetric(vertical: 0.5.rem, horizontal: 1.rem),
          radius: .circular(16.px),
          raw: {
            'background':
                'radial-gradient(circle, rgba(0, 102, 180, 0.12) 0%, rgba(9, 56, 126, 0.04) 50%, transparent 72%)',
          },
        ),
      ]),
      css('.content-logo-img').styles(
        width: 100.percent,
        maxWidth: 13.rem,
        height: .auto,
        display: .block,
        raw: {
          'filter': 'drop-shadow(0 12px 24px rgba(0, 0, 0, 0.15))',
          'transition': 'transform 320ms cubic-bezier(0.16, 1, 0.3, 1), filter 320ms ease',
        },
      ),
      css('.content-features-grid', [
        css('&').styles(
          display: .grid,
          width: 100.percent,
          gap: .all(1.5.rem),
          margin: .only(bottom: 2.2.rem),
          raw: {'grid-template-columns': 'repeat(auto-fit, minmax(260px, 1fr))'},
        ),
      ]),
      css('.content-feature-card', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          alignItems: .start,
          textAlign: .left,
          padding: .all(1.8.rem),
          backgroundColor: surfaceLow,
          border: .all(color: borderColor, width: 1.px),
          radius: .circular(12.px),
          height: 100.percent,
          boxSizing: .borderBox,
          transition: .new('all', duration: 240.ms, curve: .easeInOut),
        ),
        css('&:hover', [
          css('&').styles(
            border: .all(color: borderColor2, width: 1.px),
            transform: .translate(y: (-3).px),
            shadow: BoxShadow(
              offsetX: 0.px,
              offsetY: 8.px,
              blur: 24.px,
              color: Color.rgba(0, 0, 0, 0.07),
            ),
          ),
          css('.subcard-icon-box').styles(
            transform: .scale(1.06),
            border: .all(color: borderColor2, width: 1.px),
          ),
          css('.icon-md').styles(
            raw: {
              'box-shadow': '0 4px 14px rgba(59, 130, 246, 0.25)',
            },
          ),
          css('.icon-dart').styles(
            raw: {
              'box-shadow': '0 4px 14px rgba(6, 182, 212, 0.25)',
            },
          ),
          css('.icon-static').styles(
            raw: {
              'box-shadow': '0 4px 14px rgba(245, 158, 11, 0.25)',
            },
          ),
          css('.subcard-badge').styles(
            color: textBlack,
            border: .all(color: borderColor2, width: 1.px),
          ),
        ]),
        css('.subcard-header', [
          css('&').styles(
            display: .flex,
            alignItems: .center,
            justifyContent: .spaceBetween,
            width: 100.percent,
            margin: .only(bottom: 1.2.rem),
          ),
        ]),
        css('.subcard-icon-box', [
          css('&').styles(
            width: 2.8.rem,
            height: 2.8.rem,
            radius: .circular(10.px),
            display: .flex,
            alignItems: .center,
            justifyContent: .center,
            border: .all(color: borderColor, width: 1.px),
            backgroundColor: surface,
            raw: {'transition': 'all 260ms cubic-bezier(0.16, 1, 0.3, 1)'},
          ),
        ]),
        css('.icon-md').styles(color: Color('#3b82f6')),
        css('.icon-dart').styles(color: Color('#06b6d4')),
        css('.icon-static').styles(color: Color('#f59e0b')),
        css('.subcard-badge', [
          css('&').styles(
            padding: .symmetric(horizontal: 0.55.rem, vertical: 0.25.rem),
            radius: .circular(6.px),
            fontSize: 0.72.rem,
            fontWeight: .w600,
            color: textDim,
            backgroundColor: surface,
            border: .all(color: borderColor, width: 1.px),
            raw: {'transition': 'all 240ms ease'},
          ),
        ]),
        css('h4').styles(
          fontSize: 1.2.rem,
          fontWeight: .w600,
          margin: .only(top: .zero, bottom: 0.5.rem),
          color: textBlack,
        ),
        css('p').styles(
          fontSize: 0.95.rem,
          color: textDark,
          lineHeight: 1.5.em,
          margin: .zero,
        ),
      ]),
      css('.content-card-action').styles(
        display: .flex,
        justifyContent: .center,
        alignItems: .center,
        width: 100.percent,
      ),
    ]),
    css.media(.screen(maxWidth: 820.px), [
      css('#content-teaser .content-featured-card').styles(padding: .all(1.5.rem)),
      css('#content-teaser .content-card-top').styles(
        flexDirection: .column,
        alignItems: .center,
        gap: .row(1.5.rem),
      ),
      css('#content-teaser .content-card-text').styles(
        alignItems: .center,
        textAlign: .center,
      ),
      css('#content-teaser .content-badge').styles(justifyContent: .center),
      css('#content-teaser .content-card-desc').styles(
        fontSize: 1.rem,
        textAlign: .center,
      ),
      css('#content-teaser .content-logo-preview').styles(
        width: 100.percent,
        maxWidth: 14.rem,
      ),
      css('#content-teaser .content-logo-img').styles(
        maxWidth: 10.rem,
      ),
    ]),
  ];
}
