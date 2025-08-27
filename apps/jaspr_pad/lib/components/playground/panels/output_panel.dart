import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../../providers/project_provider.dart';
import '../output/execution_iframe.dart';

class OutputPanel extends StatelessComponent {
  const OutputPanel({super.key});

  @override
  Component build(BuildContext context) {
    var isTutorial = context.watch(isTutorialProvider);

    return div(
      id: 'output-panel',
      styles: isTutorial ? Styles(width: Unit.auto) : null,
      [ExecutionIFrame()],
    );
  }
}
