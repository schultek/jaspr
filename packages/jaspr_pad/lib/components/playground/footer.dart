import 'package:jaspr/jaspr.dart';

class PlaygroundFooter extends StatelessComponent {
  const PlaygroundFooter({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'footer',
      children: buildChildren(context).toList(),
    );
  }

  Iterable<Component> buildChildren(BuildContext context) sync* {
    yield DomComponent(
      tag: 'i',
      id: 'keyboard-button',
      classes: ['material-icons', 'footer-item'],
      attributes: {'aria-hidden': 'true'},
      child: Text('keyboard'),
    );

    yield DomComponent(
      tag: 'div',
      classes: ['footer-item'],
      children: [
        DomComponent(
          tag: 'a',
          classes: ['footer-item'],
          attributes: {
            'href': 'https://dart.dev/tools/dartpad/privacy',
            'target': 'repo',
          },
          child: Text('Privacy notice'),
        ),
        DomComponent(
          tag: 'a',
          attributes: {
            'href': 'https://github.com/dart-lang/dart-pad/issues',
            'target': 'repo',
          },
          child: Text('Send feedback'),
        ),
      ],
    );
  }
}
