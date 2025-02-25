// ignore_for_file: file_names

import 'package:jaspr/jaspr.dart';

import '../../../../constants/theme.dart';
import '../components/devex_box.dart';

class Run extends StatelessComponent {
  const Run({super.key});

  final lines = const [
    ('[CLI] ', Colors.darkTurquoise, 'Running jaspr in static rendering mode.'),
    ('[CLI] ', Colors.darkTurquoise, 'Starting web compiler...'),
    ('[BUILDER] ', Colors.purple, 'Connecting to the build daemon...'),
    ('[BUILDER] ', Colors.purple, 'About to build [web]...'),
    ('[CLI] ', Colors.darkTurquoise, 'Building web assets...'),
    ('[BUILDER] ', Colors.purple, 'Running build...'),
    ('[BUILDER] ', Colors.purple, 'Running build completed.'),
    ('[CLI] ', Colors.darkTurquoise, 'Done building web assets.'),
    ('[CLI] ', Colors.darkTurquoise, 'Starting server...'),
    ('[SERVER] ', Colors.gold, '[INFO] Server hot reload is enabled.'),
    ('[SERVER] ', Colors.gold, '[INFO] Running server in debug mode'),
    ('[SERVER] ', Colors.gold, 'Serving at http://localhost:8080'),
  ];

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DevexBox(
      caption: 'RUN',
      title: 'Jaspr CLI',
      description: text('Create, serve and build your site using simple cli commands.'),
      preview: div(classes: 'run-preview', [
        code(classes: 'console', [
          text(r'$'),
          text(' jaspr serve'),
          br(),
          for (final line in lines) ...[
            span([
              span(styles: Styles(color: line.$2), [text(line.$1)]),
              text(line.$3)
            ]),
            br(),
          ],
        ])
      ]),
    );
  }

  @css
  static final List<StyleRule> styles = [
    css('.run-preview', [
      css('&').styles(padding: Padding.all(.5.rem)),
      css('.console').styles(
        display: Display.block,
        opacity: .8,
        color: textBlack,
        textAlign: TextAlign.start,
        fontSize: .7.rem,
      ),
    ]),
  ];
}
