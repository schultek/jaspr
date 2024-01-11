import 'package:jaspr/jaspr.dart';

class PlaygroundFooter extends StatelessComponent {
  const PlaygroundFooter({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield footer([
      i(
        id: 'keyboard-button',
        classes: ['material-icons', 'footer-item'],
        attributes: {'aria-hidden': 'true'},
        [text('keyboard')],
      ),
      div(classes: [
        'footer-item'
      ], [
        a(
          href: 'https://dart.dev/tools/dartpad/privacy',
          target: Target.blank,
          classes: ['footer-item'],
          [text('Privacy notice')],
        ),
        a(
          href: 'https://github.com/schultek/jaspr/issues',
          target: Target.blank,
          [text('Send feedback')],
        ),
      ])
    ]);
  }
}
