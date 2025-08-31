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
  Component build(BuildContext context) {
    return fragment([
      div(classes: 'main', [
        img(src: 'images/logo.svg', width: 80),
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
      ]),
      footer([
        text('💙 Built with '),
        a(href: "https://github.com/schultek/jaspr", [text('Jaspr')]),
        text(' by '),
        a(href: "https://x.com/schultek_dev", [text('@schultek')]),
        text(' 💙'),
        br(),
        a(href: "https://github.com/schultek/jaspr/tree/main/examples/flutter_multi_view", [text('See the code')]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
        css('.main', [
          css('&').styles(
            display: Display.flex,
            minHeight: 80.vh,
            flexDirection: FlexDirection.column,
            alignItems: AlignItems.center,
          ),
          css('.buttons', [
            css('&').styles(
              display: Display.flex,
              flexDirection: FlexDirection.row,
            ),
            css('button').styles(
              padding: Padding.all(8.px),
              border: Border(color: primaryColor, width: 1.px),
            ),
            css('button:first-child').styles(
              margin: Margin.only(right: (-1).px),
              radius: BorderRadius.horizontal(left: Radius.circular(6.px)),
            ),
            css('button:last-child').styles(
              margin: Margin.only(left: (-1).px),
              radius: BorderRadius.horizontal(right: Radius.circular(6.px)),
            ),
          ]),
          css('.counters', [
            css('&').styles(
              display: Display.flex,
              flexDirection: FlexDirection.row,
              flexWrap: FlexWrap.wrap,
              justifyContent: JustifyContent.center,
            ),
          ]),
        ]),
        css('footer').styles(
          margin: Margin.all(40.px),
          textAlign: TextAlign.center,
          fontSize: 12.px,
          fontStyle: FontStyle.italic,
        ),
      ];
}
