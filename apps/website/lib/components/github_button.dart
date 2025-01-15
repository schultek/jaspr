import 'dart:convert';

import 'package:jaspr/jaspr.dart';

import 'package:http/http.dart' as http;

import 'icon.dart';

@client
class GithubButton extends StatefulComponent {
  const GithubButton({super.key});

  @override
  State createState() => GithubButtonState();
}

class GithubButtonState extends State<GithubButton> {
  bool loaded = false;

  int stars = 9999;
  int forks = 99;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      loadRepositoryData();
    }
  }

  Future<void> loadRepositoryData() async {
    final response = await http.get(Uri.parse('https://api.github.com/repos/schultek/jaspr'));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final {"stargazers_count": int stars, "forks_count": int forks} = data;

    setState(() {
      this.stars = stars;
      this.forks = forks;
      loaded = true;
    });
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield a(href: 'https://github.com/schultek/jaspr', classes: 'github-button', [
      Icon('custom-github', size: 1.2.rem),
      div([
        span([text('schultek/jaspr')]),
        span([
          Icon('star'),
          span(styles: !loaded ? Styles.box(opacity: 0) : null, [text('$stars')]),
          span([]),
          Icon('git-fork'),
          span(styles: !loaded ? Styles.box(opacity: 0) : null, [text('$forks')])
        ])
      ])
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('.github-button', [
      css('&')
          .box(
            padding: EdgeInsets.symmetric(horizontal: 0.7.rem, vertical: 0.4.rem),
            radius: BorderRadius.circular(8.px),
          )
          .text(decoration: TextDecoration.none, color: Colors.black, fontSize: 0.7.rem)
          .flexbox(alignItems: AlignItems.center, gap: Gap(column: .5.rem)),
      css('&:hover').background(color: Colors.whiteSmoke),
      css('& *').box(transition: Transition('opacity', duration: 200, curve: Curve.easeInOut)),
      css('&:hover *').raw({'opacity': '1 !important'}),
      css('& > i').box(opacity: 0.9),
      css('div', [
        css('&').flexbox(direction: FlexDirection.column),
        css('& > span:first-child')
            .text(fontFamily: FontFamily.list([FontFamilies.monospace]))
            .box(opacity: 0.8, margin: EdgeInsets.only(bottom: 2.px)),
        css('& > span:last-child')
            .text(fontSize: 0.9.em)
            .box(opacity: 0.6)
            .flexbox(alignItems: AlignItems.center, gap: Gap(column: .3.em)),
      ]),
    ]),
  ];
}
