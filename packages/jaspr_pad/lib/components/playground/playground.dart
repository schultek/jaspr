import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../providers/logic_provider.dart';
import '../../providers/project_provider.dart';
import '../elements/dialog.dart';
import 'footer.dart';
import 'header.dart';
import 'main.dart';

class Playground extends StatelessComponent {
  const Playground({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    context.listen(loadedProjectProvider, (_, proj) {
      if (proj != null) {
        Future.microtask(() {
          context.read(logicProvider).compileFiles();
        });
      }
    });

    yield PlaygroundHeader();
    yield MainSection();
    yield PlaygroundFooter();
    yield DialogSlot(slotId: 'dialog');
  }
}
