import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../../providers/project_provider.dart';
import '../output/execution_iframe.dart';

class OutputPanel extends StatelessComponent {
  const OutputPanel({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var isTutorial = context.watch(isTutorialProvider);

    yield DomComponent(
      tag: 'div',
      id: 'output-panel',
      styles: isTutorial ? Styles.raw({'width': 'auto'}) : null,
      child: ExecutionIFrame(),
    );
  }
}
