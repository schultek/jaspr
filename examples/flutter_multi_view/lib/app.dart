import 'package:jaspr/jaspr.dart';
import 'package:jaspr_flutter_embed/jaspr_flutter_embed.dart';

import 'components/counter.dart';

@client
class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  int counters = 2;

  @override
  void initState() {
    super.initState();
    FlutterEmbedView.preload();
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'main', [
      section([
        img(src: 'images/logo.png', width: 80),
        button(onClick: () {
          setState(() => counters++);
        }, [text("More Counters")]),
        button(onClick: () {
          setState(() => counters--);
        }, [text("Less Counters")]),
        div(classes: 'counters', [
          for (var i = 0; i < counters; i++) div([const Counter()]),
        ]),
      ])
    ]);
  }

  @css
  static final styles = [
    css('.main', [
      css('&').flexbox(direction: FlexDirection.row, wrap: FlexWrap.wrap),
      css('section').flexItem(flex: Flex(grow: 1, shrink: 0, basis: FlexBasis(400.px))).flexbox(
            direction: FlexDirection.column,
            justifyContent: JustifyContent.center,
            alignItems: AlignItems.center,
          ),
    ]),
    css('.counters').grid(
      template: GridTemplate(
        columns: GridTracks([
          GridTrack(TrackSize.fr(1)),
          GridTrack(TrackSize.fr(1)),
          GridTrack(TrackSize.fr(1)),
        ]),
      ),
    ),
    css('.counters > div').box(padding: EdgeInsets.all(20.px)),
  ];
}
