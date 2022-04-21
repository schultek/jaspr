import 'package:jaspr/jaspr.dart';
import 'package:jaspr_pad/providers/logic_provider.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../providers/gist_provider.dart';
import '../../utils/utils.dart';
import '../elements/button.dart';

class PlaygroundHeader extends StatelessComponent {
  const PlaygroundHeader({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'header',
      classes: ['mdc-elevation--z4'],
      children: buildChildren(context).toList(),
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
          onPressed: () {
            context.read(logicProvider).newPad();
          },
        ),
        Button(
          id: 'reset-button',
          label: 'Reset',
          icon: 'refresh',
          onPressed: () {
            context.read(logicProvider).refresh();
          },
        ),
        Button(
          id: 'jformat-button',
          label: 'Format',
          icon: 'format_align_left',
          onPressed: () {
            context.read(logicProvider).formatDartFiles();
          },
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

    yield Builder(builder: (context) sync* {
      var name = context.watch(gistNameProvider);
      if (name != null) {
        yield DomComponent(tag: 'div', classes: ['header-gist-name'], child: Text(name));
      }
    });
  }
}
