import 'package:jaspr/jaspr.dart';

class PlaygroundFooter extends StatelessComponent {
  const PlaygroundFooter({super.key});

  @override
  Component build(BuildContext context) {
    return footer([
      //   i(
      //     id: 'keyboard-button',
      //     classes: ['material-icons', 'footer-item'],
      //     attributes: {'aria-hidden': 'true'},
      //     [text('keyboard')],
      //   ),
      div(classes: 'footer-item', [
        a(href: 'https://docs.jaspr.site', target: Target.blank, classes: 'footer-item', [text('Jaspr Docs')]),
        a(href: 'https://discord.gg/XGXrGEk4c6', target: Target.blank, classes: 'footer-item', [
          text('Join the Community'),
        ]),
        a(href: 'https://github.com/schultek/jaspr/issues', target: Target.blank, [text('Send feedback')]),
      ]),
    ]);
  }
}
