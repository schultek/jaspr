import 'package:jaspr/jaspr.dart';

import '../../utils/utils.dart';
import '../elements/button.dart';

class PlaygroundHeader extends StatelessComponent {
  const PlaygroundHeader({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'header',
      classes: ['mdc-elevation--z4'],
      children: buildChildren(context),
    );
  }

  Iterable<Component> buildChildren(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: ['header-title'],
      children: [
        DomComponent(
          tag: 'img',
          classes: ['logo'],
          attributes: {
            'src': "https://dartpad.dev/dart-192.png",
            'alt': "DartPad Logo",
          },
        ),
        DomComponent(
          tag: 'span',
          child: Text('JasprPad'),
        ),
      ],
    );

    yield DomComponent(
      tag: 'div',
      children: [
        Button(
          id: 'jnew-button',
          label: 'New Pad',
          icon: 'code',
          onPressed: () {},
        ),
        Button(
          id: 'reset-button',
          label: 'Reset',
          icon: 'refresh',
          onPressed: () {},
        ),
        Button(
          id: 'jformat-button',
          label: 'Format',
          icon: 'format_align_left',
          onPressed: () {},
        ),
        Button(
          id: 'jinstall-button',
          label: 'Install SDK',
          icon: 'get_app',
          onPressed: () {
            open('https://dart.dev/get-dart');
          },
        ),
      ],
    );
  }
}
