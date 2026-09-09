import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

import '../../../components/link_button.dart';
import '../../../constants/theme.dart';
import 'components/showcase_card.dart';
import 'data/showcase_data.dart';

class Showcase extends StatelessComponent {
  const Showcase({super.key});

  @override
  Component build(BuildContext context) {
    final allItems = ShowcaseItem.fromData(context.page.data['showcase']);
    final homeItems = allItems.take(6).toList();

    return section(id: 'showcase', [
      div(classes: 'showcase-header', [
        span(classes: 'caption text-gradient', [.text('Showcase')]),
        h2([
          .text('Built with '),
          span(classes: 'text-gradient', [.text('Jaspr')]),
        ]),
      ]),
      div(classes: 'showcase-grid-wrapper', [
        div(classes: 'showcase-grid', [
          for (final item in homeItems) ShowcaseCard(item: item, compact: false),
        ]),
        div(classes: 'showcase-overlay-action', [
          LinkButton.filled(
            label: 'View All',
            icon: 'arrow-right',
            to: '/showcase',
          ),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('#showcase', [
      css('&').styles(
        display: .flex,
        padding: .only(top: 4.rem),
        flexDirection: .column,
        alignItems: .center,
        boxSizing: .borderBox,
        width: 100.percent,
        overflow: .hidden,
      ),
      css('.showcase-header', [
        css('&').styles(
          display: .flex,
          maxWidth: maxContentWidth,
          padding: .symmetric(horizontal: contentPadding),
          flexDirection: .column,
          alignItems: .center,
          textAlign: .center,
          margin: .only(bottom: 2.5.rem),
          boxSizing: .borderBox,
        ),
      ]),
      css('.showcase-grid-wrapper', [
        css('&').styles(
          position: .relative(),
          width: 100.percent,
          maxWidth: maxContentWidth,
          padding: .symmetric(horizontal: contentPadding),
          boxSizing: .borderBox,
        ),
      ]),
      css('.showcase-grid', [
        css('&').styles(
          display: .grid,
          width: 100.percent,
          gap: .all(1.8.rem),
          boxSizing: .borderBox,
          raw: {
            'grid-template-columns': 'repeat(3, 1fr)',
            'mask-image': 'linear-gradient(to bottom, rgba(0, 0, 0, 1) 0%, rgba(0, 0, 0, 1) 40%, rgba(0, 0, 0, 0) 92%)',
            '-webkit-mask-image':
                'linear-gradient(to bottom, rgba(0, 0, 0, 1) 0%, rgba(0, 0, 0, 1) 40%, rgba(0, 0, 0, 0) 92%)',
          },
        ),
        css('& > *:nth-child(n+7)').styles(display: .none),
      ]),
      css('.showcase-overlay-action', [
        css('&').styles(
          position: .absolute(bottom: 3.5.rem, left: .zero, right: .zero),
          display: .flex,
          justifyContent: .center,
          alignItems: .center,
          zIndex: .new(10),
          raw: {'pointer-events': 'auto'},
        ),
      ]),
    ]),
    css.media(.screen(maxWidth: 880.px), [
      css('#showcase .showcase-grid').styles(
        gap: .all(1.2.rem),
        raw: {
          'grid-template-columns': 'repeat(2, 1fr)',
          'mask-image': 'linear-gradient(to bottom, rgba(0, 0, 0, 1) 0%, rgba(0, 0, 0, 1) 40%, rgba(0, 0, 0, 0) 92%)',
          '-webkit-mask-image':
              'linear-gradient(to bottom, rgba(0, 0, 0, 1) 0%, rgba(0, 0, 0, 1) 40%, rgba(0, 0, 0, 0) 92%)',
        },
      ),
      css('#showcase .showcase-grid > *:nth-child(n+5)').styles(display: .none),
      css('#showcase .showcase-overlay-action').styles(
        position: .absolute(bottom: 2.5.rem, left: .zero, right: .zero),
      ),
    ]),
    css.media(.screen(maxWidth: 580.px), [
      css('#showcase .showcase-grid').styles(
        gap: .all(1.rem),
        raw: {
          'grid-template-columns': '1fr',
          'mask-image': 'linear-gradient(to bottom, rgba(0, 0, 0, 1) 0%, rgba(0, 0, 0, 1) 42%, rgba(0, 0, 0, 0) 92%)',
          '-webkit-mask-image':
              'linear-gradient(to bottom, rgba(0, 0, 0, 1) 0%, rgba(0, 0, 0, 1) 42%, rgba(0, 0, 0, 0) 92%)',
        },
      ),
      css('#showcase .showcase-grid > *:nth-child(n+3)').styles(display: .none),
      css('#showcase .showcase-overlay-action').styles(
        position: .absolute(bottom: 2.rem, left: .zero, right: .zero),
      ),
      css('#showcase h2').styles(fontSize: 1.8.rem),
      css('#showcase .showcase-header p').styles(fontSize: 0.95.rem),
    ]),
  ];
}
