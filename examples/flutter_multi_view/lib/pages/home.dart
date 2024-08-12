import 'package:jaspr/jaspr.dart';

import '../components/counter.dart';

class Home extends StatefulComponent {
  const Home({super.key});

  State createState() => HomeState();
}

class HomeState extends State<Home> {
  int counters = 1;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield section([
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
    ]);
  }

  @css
  static final styles = [
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
