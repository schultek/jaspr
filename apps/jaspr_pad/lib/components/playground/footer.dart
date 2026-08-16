import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../providers/settings_provider.dart';

class PlaygroundFooter extends StatelessComponent {
  const PlaygroundFooter({super.key});

  @override
  Component build(BuildContext context) {
    return footer([
      Builder(builder: (context) {
        final isVim = context.watch(keyMapProvider) == 'vim';
        return i(
          id: 'keyboard-button',
          classes: 'material-icons footer-item',
          styles: isVim ? Styles(raw: {'color': '#4CAF50'}) : null,
          attributes: {
            'aria-hidden': 'true',
            'title': isVim ? 'Vim mode enabled (Cmd+Shift+/ to toggle)' : 'Enable vim mode (Cmd+Shift+/ to toggle)',
          },
          events: {
            'click': (_) => toggleVimMode(context),
          },
          [.text('keyboard')],
        );
      }),
      div(classes: 'footer-item', [
        a(href: 'https://docs.jaspr.site', target: Target.blank, classes: 'footer-item', [.text('Jaspr Docs')]),
        a(href: 'https://discord.gg/XGXrGEk4c6', target: Target.blank, classes: 'footer-item', [
          .text('Join the Community'),
        ]),
        a(href: 'https://github.com/schultek/jaspr/issues', target: Target.blank, [.text('Send feedback')]),
      ]),
    ]);
  }
}
