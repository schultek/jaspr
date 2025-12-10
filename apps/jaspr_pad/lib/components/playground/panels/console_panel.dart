import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../output/execution_service.dart';

class ConsolePanel extends StatelessComponent {
  const ConsolePanel({super.key});

  @override
  Component build(BuildContext context) {
    var messages = context.watch(consoleMessagesProvider);

    return div(
      classes: 'console custom-scrollbar',
      styles: Styles(display: Display.flex, flexDirection: FlexDirection.column),
      [
        for (var msg in messages) span(styles: Styles(width: Unit.zero), [RawText(msg)]),
      ],
    );
  }
}
