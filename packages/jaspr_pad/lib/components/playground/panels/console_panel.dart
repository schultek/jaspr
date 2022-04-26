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
      styles: {'display': 'flex', 'flex-direction': 'column'},
      classes: ['console', 'custom-scrollbar'],
      children: [
        for (var msg in messages)
          DomComponent(
            tag: 'span',
            styles: {'width': '0'},
            child: Text(msg, rawHtml: true),
          ),
      ],
    );
  }
}
