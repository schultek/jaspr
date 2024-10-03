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
      img(src: 'images/logo.png', width: 80),
      div(classes: 'buttons', [
        button(
          onClick: () {
            setState(() => counters--);
          },
          [text('Less Counters')],
        ),
        button(
          onClick: () {
            setState(() => counters++);
          },
          [text('More Counters')],
        ),
      ]),
      div(classes: 'counters', [
        for (var i = 0; i < counters; i++)
          div(classes: 'counter-group', [
            const Counter(),
          ]),
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
        css('.counter-group').box(
            margin: EdgeInsets.all(10.px),
            padding: EdgeInsets.all(10.px),
            border: Border.all(BorderSide.dashed(width: 1.px, color: Colors.lightGrey)),
            radius: BorderRadius.circular((cardBorderRadius + 10).px)),
      ]),
    ]),
  ];
}
