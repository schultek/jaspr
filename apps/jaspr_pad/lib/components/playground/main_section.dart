import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../providers/project_provider.dart';
import '../elements/snackbar.dart';
import '../elements/splitter.dart';
import 'panels/editor_panel.dart';
import 'panels/output_panel.dart';
import 'panels/tutorial_panel.dart';

class MainSection extends StatelessComponent {
  const MainSection({super.key});

  @override
  Component build(BuildContext context) {
    var isTutorial = context.watch(isTutorialProvider);

    return section(classes: 'main-section', [
      div(classes: 'panels', [
        Splitter(
          children: [
            if (isTutorial) TutorialPanel(),
            EditorPanel(),
            if (!isTutorial) OutputPanel(),
          ],
        )
      ]),
      SnackBar(),
    ]);
  }
}
