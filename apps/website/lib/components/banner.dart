import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

import '../constants/theme.dart';

class Banner extends StatelessComponent {
  const Banner({super.key});

  @override
  Component build(BuildContext context) {
    final banner = context.page.data.site['banner'] as Map<String, Object?>? ?? {};
    if (banner['enabled'] == false) return .empty();

    final text = (banner['text'] as String).split('{{link}}');
    final linkText = banner['linkText'] as String? ?? '';
    final link = banner['link'] as String? ?? '';

    return div(
      id: 'site-banner',
      attributes: {'role': 'alert'},
      [
        p([
          .text(text[0]),
          if (text.length > 1) ...[
            a(classes: 'animated-underline', href: link, target: .blank, [.text(linkText)]),
            .text(text.skip(1).join('')),
          ],
        ]),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('#site-banner', [
      css('&').styles(
        display: .flex,
        zIndex: .new(10),
        width: 100.percent,
        padding: .all(0.75.rem),
        boxSizing: .borderBox,
        justifyContent: .center,
        alignItems: .center,
        gap: .column(0.5.rem),
        color: Colors.white,
        textAlign: .center,
        raw: {'background': 'linear-gradient(139deg, ${primaryDark.value}, ${primaryMid.value})'},
      ),
      css('p').styles(
        margin: .zero,
        flex: .grow(1),
        color: Colors.white,
        raw: {'overflow-wrap': 'anywhere', 'word-break': 'normal', 'text-wrap': 'balance'},
      ),
      css('a', [
        css('&').styles(
          color: primaryLight.withLightness(0.2, replace: false),
          whiteSpace: .noWrap,
        ),
        css('&:hover').styles(
          color: primaryLight.withLightness(0, replace: false),
        ),
        css('&:active').styles(
          color: primaryLight,
        ),
      ]),
    ]),
  ];
}
