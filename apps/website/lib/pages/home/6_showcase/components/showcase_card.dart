import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../components/icon.dart';
import '../../../../constants/theme.dart';
import '../data/showcase_data.dart';

class ShowcaseCard extends StatelessComponent {
  final ShowcaseItem item;
  final bool compact;

  const ShowcaseCard({required this.item, this.compact = false, super.key});

  @override
  Component build(BuildContext context) {
    return a(
      classes: 'showcase-card-link${compact ? ' compact' : ''}',
      href: item.url,
      target: .blank,
      attributes: {'rel': 'noopener noreferrer'},
      [
        div(classes: 'showcase-card', [
          div(classes: 'showcase-img-wrap', [
            img(
              src: item.image,
              alt: '${item.title} screenshot',
              classes: 'showcase-thumb',
              attributes: {'loading': 'lazy'},
            ),
            span(classes: 'showcase-tag', [.text(item.category)]),
          ]),
          div(classes: 'showcase-meta', [
            div(classes: 'showcase-info', [
              h4([.text(item.title)]),
              span(classes: 'showcase-url-label', [.text(item.displayUrl)]),
            ]),
            div(classes: 'showcase-link-icon', [
              Icon('external-link', size: 0.85.em),
            ]),
          ]),
        ]),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.showcase-card-link', [
      css('&').styles(
        textDecoration: .none,
        display: .block,
        color: .inherit,
        flex: .shrink(0),
        width: 100.percent,
        boxSizing: .borderBox,
        transition: .new('transform', duration: 200.ms, curve: .easeInOut),
      ),
      css('&.compact').styles(
        width: 20.rem,
      ),
      css('&:hover').styles(
        transform: .translate(y: (-4).px),
      ),
      css('&:hover .showcase-card').styles(
        border: .all(color: borderColor2, width: 1.px),
        shadow: BoxShadow(
          offsetX: 0.px,
          offsetY: 6.px,
          blur: 16.px,
          color: Color.rgba(0, 0, 0, 0.08),
        ),
      ),
      css('&:hover h4').styles(color: primaryMid),
      css('&:hover .showcase-url-label').styles(color: primaryMid),
      css('&:hover .showcase-link-icon').styles(color: primaryMid),
    ]),
    css('.showcase-card', [
      css('&').styles(
        display: .flex,
        flexDirection: .column,
        backgroundColor: surface,
        border: .all(color: borderColor, width: 1.px),
        radius: .circular(12.px),
        overflow: .hidden,
        boxSizing: .borderBox,
        transition: .new('all', duration: 200.ms, curve: .easeInOut),
      ),
      css('.showcase-img-wrap', [
        css('&').styles(
          position: .relative(),
          width: 100.percent,
          aspectRatio: .new(16, 10),
          overflow: .hidden,
          backgroundColor: surfaceLow,
        ),
        css('.showcase-thumb').styles(
          width: 100.percent,
          height: 100.percent,
          display: .block,
          raw: {
            'object-fit': 'cover',
            'object-position': 'top center',
            'transition': 'transform 300ms ease-in-out',
          },
        ),
        css('.showcase-tag').styles(
          position: .absolute(top: 0.6.rem, right: 0.6.rem),
          padding: .symmetric(horizontal: 0.6.rem, vertical: 0.2.rem),
          radius: .circular(6.px),
          fontSize: 0.7.rem,
          fontWeight: .w700,
          color: Colors.white,
          raw: {
            'background': 'rgba(0, 0, 0, 0.75)',
            'backdrop-filter': 'blur(4px)',
            '-webkit-backdrop-filter': 'blur(4px)',
          },
        ),
      ]),
      css('&:hover .showcase-thumb').styles(
        transform: .scale(1.03),
      ),
      css('.showcase-meta', [
        css('&').styles(
          display: .flex,
          justifyContent: .spaceBetween,
          alignItems: .center,
          padding: .symmetric(horizontal: 1.1.rem, vertical: 0.9.rem),
          gap: .column(0.5.rem),
        ),
        css('h4').styles(
          fontSize: 1.05.rem,
          fontWeight: .w600,
          color: textBlack,
          margin: .zero,
          raw: {
            'overflow': 'hidden',
            'text-overflow': 'ellipsis',
            'white-space': 'nowrap',
            'transition': 'color 150ms ease',
          },
        ),
        css('.showcase-url-label').styles(
          fontSize: 0.8.rem,
          color: textDim,
          margin: .only(top: 0.2.rem),
          display: .block,
          raw: {
            'transition': 'color 150ms ease',
          },
        ),
        css('.showcase-link-icon').styles(
          color: textDim,
          flex: .shrink(0),
          raw: {
            'transition': 'color 150ms ease',
          },
        ),
      ]),
    ]),
  ];
}
