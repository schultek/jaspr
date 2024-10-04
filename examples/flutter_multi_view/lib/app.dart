import 'package:jaspr/jaspr.dart';
import 'package:jaspr_flutter_embed/jaspr_flutter_embed.dart';

import 'components/counter.dart';
import 'constants/theme.dart';

@client
class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> with ViewTransitionMixin<App> {
  List<String> counters = ['counter-1', 'counter-2'];

  @override
  void initState() {
    super.initState();
    FlutterEmbedView.preload();
  }

  void addCounter() async {
    setStateWithViewTransition(() {
      counters.add('targeted-counter');
    }, postTransition: () {
      counters[counters.length - 1] = 'counter-${counters.length}';
    });
  }

  void removeCounter() {
    setStateWithViewTransition(preTransition: () {
      counters[counters.length - 1] = 'targeted-counter';
    }, () {
      counters.removeLast();
    });
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'main', [
      img(src: 'images/logo.png', width: 80),
      div(classes: 'buttons', [
        button(
          onClick: () {
            removeCounter();
          },
          [text('Less Counters')],
        ),
        button(
          onClick: () {
            addCounter();
          },
          [text('More Counters')],
        ),
      ]),
      div(classes: 'counters', [
        for (var name in counters) Counter(name: name),
      ]),
    ]);
  }

  @css
  static final styles = [
    css('.main', [
      css('&').flexbox(direction: FlexDirection.column, alignItems: AlignItems.center),
      css('.buttons', [
        css('&').flexbox(direction: FlexDirection.row),
        css('button')
            .box(padding: EdgeInsets.all(8.px), border: Border.all(BorderSide.solid(color: primaryColor, width: 1.px))),
        css('button:first-child')
            .box(radius: BorderRadius.horizontal(left: Radius.circular(6.px)), margin: EdgeInsets.only(right: (-1).px)),
        css('button:last-child')
            .box(radius: BorderRadius.horizontal(right: Radius.circular(6.px)), margin: EdgeInsets.only(left: (-1).px)),
      ]),
      css('.counters', [
        css('&').flexbox(
          direction: FlexDirection.row,
          wrap: FlexWrap.wrap,
          justifyContent: JustifyContent.center,
        ),
      ]),
    ]),
  ];
}
