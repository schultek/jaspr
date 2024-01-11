import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../output/execution_service.dart';

class ConsolePanel extends StatelessComponent {
  const ConsolePanel({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var messages = context.watch(consoleMessagesProvider);

    yield div(
      styles: Styles.flexbox(direction: FlexDirection.column),
      classes: ['console', 'custom-scrollbar'],
      [
        for (var msg in messages)
          span(styles: Styles.box(width: Unit.zero), [
            text(msg, rawHtml: true),
          ]),
      ],
    );
  }
}
