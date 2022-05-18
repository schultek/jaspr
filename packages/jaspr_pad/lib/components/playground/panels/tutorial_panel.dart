import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../../models/tutorial.dart';
import '../../../providers/edit_provider.dart';
import '../../../providers/logic_provider.dart';
import '../../elements/button.dart';
import '../../elements/markdown.dart';
import 'output_split_view.dart';

class TutorialPanel extends StatelessComponent {
  const TutorialPanel({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var tutorial = context.watch(editProjectProvider);

    if (tutorial is! TutorialData) {
      return;
    }

    yield DomComponent(
      tag: 'div',
      id: 'steps-panel',
      children: [
        DomComponent(
          tag: 'div',
          id: 'markdown-content',
          classes: ['custom-scrollbar'],
          children: [
            Markdown(markdown: tutorial.step.text),
          ],
        ),
        DomComponent(
          tag: 'div',
          id: 'steps-row',
          children: [
            DomComponent(
              tag: 'div',
              id: 'step-button-container',
              children: [
                Button(
                  icon: 'keyboard_arrow_left',
                  disabled: tutorial.currentStep == 0,
                  onPressed: () {
                    context.read(logicProvider).prevTutorialStep();
                  },
                ),
                DomComponent(
                  tag: 'div',
                  id: 'steps-container',
                  children: [
                    DomComponent(
                      tag: 'div',
                      id: 'steps-label',
                      child: Text(tutorial.configs[tutorial.currentStep].name),
                    ),
                    DomComponent(
                      tag: 'div',
                      id: 'steps-menu-items',
                      children: [
                        for (var step in tutorial.configs.reversed)
                          DomComponent(
                            tag: 'a',
                            classes: ['step-menu-item'],
                            events: {
                              'click': (_) {
                                context.read(logicProvider).selectTutorialStep(step.id);
                              }
                            },
                            child: Text(step.name),
                          ),
                      ],
                    ),
                  ],
                ),
                Button(
                  icon: 'keyboard_arrow_right',
                  disabled: tutorial.currentStep == tutorial.configs.length - 1,
                  onPressed: () {
                    context.read(logicProvider).nextTutorialStep();
                  },
                ),
              ],
            ),
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
          ],
        )
      ],
    );
  }
}
