import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../output/execution_service.dart';

class ConsolePanel extends StatelessComponent {
  const ConsolePanel({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var messages = context.watch(consoleMessagesProvider);

    yield DomComponent(
      tag: 'div',
      styles: Styles.flexbox(direction: FlexDirection.column),
      classes: ['console', 'custom-scrollbar'],
      children: [
        for (var msg in messages)
          DomComponent(
            tag: 'span',
            styles: Styles.box(width: Unit.zero),
            child: Text(msg, rawHtml: true),
          ),
      ],
    );
  }
}
