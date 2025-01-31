import 'package:jaspr/jaspr.dart';
import 'package:website/constants/theme.dart';

class AnimatedConsole extends StatefulComponent {
  const AnimatedConsole({super.key});

  @override
  State createState() => AnimatedConsoleState();
}

class AnimatedConsoleState extends State<AnimatedConsole> {
  final lines = [
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
    yield code(classes: 'console', [
      text(r'$'),
      text(' jaspr serve'),
      br(),
      for (final line in lines) ...[
        span([
          span(styles: Styles.text(color: line.$2), [text(line.$1)]),
          text(line.$3)
        ]),
        br(),
      ],
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('.console')
        .box(display: Display.block, opacity: .8)
        .text(fontSize: .7.rem, align: TextAlign.start, color: textBlack),
  ];
}
