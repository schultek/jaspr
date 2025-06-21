// ignore_for_file: file_names

import 'package:jaspr/jaspr.dart';

import '../../../../components/code_window/code_window.dart';
import '../components/counter_button.dart';
import '../components/devex_box.dart';

class Develop extends StatelessComponent {
  const Develop({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DevexBox(
      caption: 'DEVELOP',
      title: 'Familiar Concepts',
      description: text('Apply your Flutter skills to build websites. '
          'Reuse already learned concepts like BuildContext, setState and much more.'),
      preview: div(classes: 'develop-preview', [
        div([
          div([
            CodeWindow(
              name: 'counter.dart',
              framed: false,
              scroll: false,
              source: '''
                Iterable<Component> build(BuildContext context) sync* {
                  yield button(
                    onClick: () {
                      setState(() => count++);
                    },
                    [ text('Clicked \$count times'), ]
                  );
                }
              ''',
            ),
            div(classes: 'counter-button', [
              CounterButton(),
            ]),
          ]),
        ]),
      ]),
    );
  }

  @css
  static List<StyleRule> get styles => [
        css('.develop-preview', [
          css('&').styles(
            position: Position.relative(),
            height: 100.percent,
            padding: Padding.all(1.rem),
            boxSizing: BoxSizing.borderBox,
          ),
          css('& > div').styles(
            position: Position.absolute(top: 50.percent, left: 47.percent),
            width: 33.rem,
            maxWidth: 100.percent,
            transform: Transform.translate(x: (-50).percent, y: (-50).percent),
          ),
          css('& > div > div').styles(
            position: Position.relative(),
          ),
          css('.counter-button').styles(
            position: Position.absolute(right: (-1.5).rem, bottom: (-0.5).rem),
          ),
        ]),
      ];
}
