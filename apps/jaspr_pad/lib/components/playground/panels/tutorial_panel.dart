import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../../models/tutorial.dart';
import '../../../providers/edit_provider.dart';
import '../../../providers/logic_provider.dart';
import '../../elements/button.dart';
import '../../elements/hidden.dart';
import '../../elements/markdown.dart';

class TutorialPanel extends StatelessComponent {
  const TutorialPanel({super.key});

  @override
  Component build(BuildContext context) {
    var tutorial = context.watch(editProjectProvider);

    if (tutorial is! TutorialData) {
      return text('');
    }

    return div(id: 'steps-panel', [
      div(id: 'markdown-content', classes: 'custom-scrollbar', [Markdown(markdown: tutorial.step.text)]),
      div(id: 'steps-row', [
        div(id: 'step-button-container', [
          Button(
            icon: 'keyboard_arrow_left',
            disabled: tutorial.currentStep == 0,
            onPressed: () {
              context.read(logicProvider).prevTutorialStep();
            },
          ),
          div(id: 'steps-container', [
            div(id: 'steps-label', [text(tutorial.configs[tutorial.currentStep].name)]),
            div(id: 'steps-menu-items', [
              for (var step in tutorial.configs.reversed)
                a(
                  href: '',
                  classes: 'step-menu-item',
                  events: events(
                    onClick: () {
                      context.read(logicProvider).selectTutorialStep(step.id);
                    },
                  ),
                  [text(step.name)],
                ),
            ]),
          ]),
          Button(
            icon: 'keyboard_arrow_right',
            disabled: tutorial.currentStep == tutorial.configs.length - 1,
            onPressed: () {
              context.read(logicProvider).nextTutorialStep();
            },
          ),
        ]),
        Hidden(
          visibilityMode: true,
          hidden: tutorial.step.solution == null,
          child: Button(
            id: 'show-solution-btn',
            label: 'Show ${tutorial.step.showSolution ? 'Source' : 'Solution'}',
            raised: true,
            dense: true,
            onPressed: () {
              context.read(logicProvider).toggleSolution();
            },
          ),
        ),
      ]),
    ]);
  }
}
