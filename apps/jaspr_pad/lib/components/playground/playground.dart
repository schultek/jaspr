import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../providers/logic_provider.dart';
import '../../providers/project_provider.dart';
import '../elements/dialog.dart';
import 'footer.dart';
import 'header.dart';
import 'main_section.dart';

class Playground extends StatelessComponent {
  const Playground({super.key});

  @override
  Component build(BuildContext context) {
    if (kIsWeb) {
      context.listen(loadedProjectProvider, (_, proj) {
        if (proj.value != null) {
          Future(() => context.read(logicProvider).compileFiles());
        }
      }, fireImmediately: true);
    }

    return fragment([PlaygroundHeader(), MainSection(), PlaygroundFooter(), DialogSlot(slotId: 'dialog')]);
  }
}
