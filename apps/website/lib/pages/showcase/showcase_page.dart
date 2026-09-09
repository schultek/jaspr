import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

import '../../components/case_study_card.dart';
import '../../components/gradient_border.dart';
import '../../components/link_button.dart';
import '../../constants/theme.dart';
import '../home/6_showcase/components/showcase_card.dart';
import '../home/6_showcase/data/showcase_data.dart';

class ShowcasePage extends StatelessComponent {
  const ShowcasePage({super.key});

  @override
  Component build(BuildContext context) {
    final items = ShowcaseItem.fromData(context.page.data['showcase']);

    return div(classes: 'showcase-page', [
          // Header
          div(classes: 'sp-hero', [
            span(classes: 'caption2 text-gradient', [.text('SHOWCASE GALLERY')]),
            h1([
              .text('Built with '),
              span(classes: 'text-gradient', [.text('Jaspr')]),
            ]),
            p(classes: 'sp-subtitle', [
              .text(
                'Explore production websites, developer tooling, documentation hubs, and web apps '
                'crafted by developers and companies across the Dart and Flutter ecosystem.',
              ),
            ]),
            div(classes: 'sp-header-actions', [
              LinkButton.outlined(
                label: 'Submit Your Project',
                icon: 'external-link',
                to: 'https://github.com/schultek/jaspr/issues/new?template=showcase_submission.md',
                target: .blank,
              ),
            ]),
          ]),

          // 1. Featured Case Study Card for Flutter & Dart
          div(classes: 'sp-featured-case-study', [
            CaseStudyCard(),
          ]),

          // 2. Full Grid of Showcases
          div(classes: 'sp-grid-section', [
            div(classes: 'sp-grid-header', [
              h3([.text('Community & Production Projects')]),
              p([.text('Browse all ${items.length} projects built with Jaspr.')]),
            ]),
            div(classes: 'sp-grid', [
              for (final item in items)
                ShowcaseCard(item: item, compact: false),
            ]),
          ]),

          // Submit Bottom Banner
          div(classes: 'sp-submit-banner', [
            GradientBorder(
              radius: 16,
              child: div(classes: 'submit-banner-content', [
                span(classes: 'caption2 text-gradient', [.text('COMMUNITY')]),
                h3([.text('Built something awesome with Jaspr?')]),
                p([
                  .text(
                    'We would love to feature your website or app on the official showcase. '
                    'Open an issue using our GitHub submission template to share your work with the community.',
                  ),
                ]),
                div(classes: 'banner-actions', [
                  LinkButton.filled(
                    label: 'Submit Your Website',
                    icon: 'external-link',
                    to: 'https://github.com/schultek/jaspr/issues/new?template=showcase_submission.md',
                    target: .blank,
                  ),
                ]),
              ]),
            ),
          ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.showcase-page', [
      css('&').styles(
        display: .flex,
        flexDirection: .column,
        alignItems: .center,
        padding: .only(top: 8.rem, bottom: 6.rem),
        boxSizing: .borderBox,
      ),
      css('.sp-hero', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          alignItems: .center,
          textAlign: .center,
          maxWidth: 50.rem,
          padding: .symmetric(horizontal: contentPadding),
          margin: .only(bottom: 3.5.rem),
          boxSizing: .borderBox,
        ),
        css('h1').styles(
          fontSize: 3.2.rem,
          fontWeight: .w800,
          margin: .only(top: 0.4.rem, bottom: 1.rem),
          raw: {'text-wrap': 'balance'},
        ),
        css('.sp-subtitle').styles(
          fontSize: 1.2.rem,
          color: textDark,
          lineHeight: 1.6.em,
          margin: .only(bottom: 2.rem),
          raw: {'text-wrap': 'balance'},
        ),
        css('.sp-header-actions').styles(
          display: .flex,
          justifyContent: .center,
        ),
      ]),
      css('.sp-featured-case-study', [
        css('&').styles(
          width: 100.percent,
          maxWidth: maxContentWidth,
          padding: .symmetric(horizontal: contentPadding),
          margin: .only(bottom: 5.rem),
          boxSizing: .borderBox,
        ),
      ]),
      css('.sp-grid-section', [
        css('&').styles(
          width: 100.percent,
          maxWidth: maxContentWidth,
          padding: .symmetric(horizontal: contentPadding),
          margin: .only(bottom: 5.rem),
          boxSizing: .borderBox,
        ),
        css('.sp-grid-header').styles(
          margin: .only(bottom: 2.5.rem),
        ),
        css('.sp-grid-header h3').styles(
          fontSize: 1.8.rem,
          fontWeight: .w700,
          margin: .only(top: .zero, bottom: 0.4.rem),
        ),
        css('.sp-grid-header p').styles(
          fontSize: 1.05.rem,
          color: textDim,
          margin: .zero,
        ),
        css('.sp-grid', [
          css('&').styles(
            display: .grid,
            gap: .all(1.8.rem),
            raw: {'grid-template-columns': 'repeat(auto-fill, minmax(320px, 1fr))'},
          ),
        ]),
      ]),
      css('.sp-submit-banner', [
        css('&').styles(
          width: 100.percent,
          maxWidth: 46.rem,
          padding: .symmetric(horizontal: contentPadding),
          boxSizing: .borderBox,
        ),
        css('.submit-banner-content').styles(
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
          margin: .only(top: 0.4.rem, bottom: 0.6.rem),
        ),
        css('p').styles(
          maxWidth: 36.rem,
          fontSize: 1.05.rem,
          color: textDark,
          lineHeight: 1.6.em,
          margin: .only(bottom: 1.8.rem),
        ),
      ]),
    ]),
    css.media(.screen(maxWidth: 850.px), [
      css('.showcase-page .featured-body').styles(flexDirection: .column),
      css('.showcase-page .sp-hero h1').styles(fontSize: 2.3.rem),
    ]),
  ];
}
