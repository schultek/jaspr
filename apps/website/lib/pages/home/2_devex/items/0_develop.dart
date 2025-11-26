// ignore_for_file: file_names

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../components/code_window/code_window.dart';
import '../components/counter_button.dart';
import '../components/devex_box.dart';

class Develop extends StatelessComponent {
  const Develop({super.key});

  @override
  Component build(BuildContext context) {
    return DevexBox(
      caption: 'DEVELOP',
      title: 'Familiar Concepts',
      description: .text(
        'Apply your Flutter skills to build websites. '
        'Reuse already learned concepts like BuildContext, setState and much more.',
      ),
      preview: div(classes: 'develop-preview', [
        div([
          div([
            CodeWindow(
              name: 'counter.dart',
              framed: false,
              scroll: false,
              source: '''
                Component build(BuildContext context) {
                  return button(
                    onClick: () {
                      setState(() => count++);
                    },
                    [ text('Clicked \$count times'), ]
                  );
                }
              ''',
            ),
            div(classes: 'counter-button', [CounterButton()]),
          ]),
        ]),
      ]),
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.develop-preview', [
      css('&').styles(
        position: .relative(),
        height: 100.percent,
        padding: .all(1.rem),
        boxSizing: .borderBox,
      ),
      css('& > div').styles(
        position: .absolute(top: 50.percent, left: 47.percent),
        width: 33.rem,
        maxWidth: 100.percent,
        transform: .translate(x: (-50).percent, y: (-50).percent),
      ),
      css('& > div > div').styles(position: .relative()),
      css('.counter-button').styles(
        position: .absolute(right: (-1.5).rem, bottom: (-0.5).rem),
      ),
    ]),
  ];
}
