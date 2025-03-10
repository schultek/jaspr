import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jaspr/jaspr.dart';

@client
class GithubButton extends StatefulComponent {
  const GithubButton({
    required this.repo,
    super.key,
  });

  final String repo;

  @override
  State createState() => GithubButtonState();
}

class GithubButtonState extends State<GithubButton> with PreloadStateMixin {
  bool loaded = false;

  int stars = 9999;
  int forks = 99;

  @override
  Future<void> preloadState() async {
    if (!kGenerateMode) {
      //await loadRepositoryData();
    }
  }

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      loadRepositoryData().then((_) {
        setState(() {});
      });
    }
  }

  Future<void> loadRepositoryData() async {
    final response = await http.get(Uri.parse('https://api.github.com/repos/${component.repo}'));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final {"stargazers_count": int stars, "forks_count": int forks} = data;

    this.stars = stars;
    this.forks = forks;
    loaded = true;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield a(href: 'https://github.com/${component.repo}', target: Target.blank, classes: 'github-button', [
      div(classes: 'github-icon', [
        raw(githubIcon),
      ]),
      div([
        span([text('schultek/jaspr')]),
        span([
          text('★'),
          span(styles: !loaded ? Styles(opacity: 0) : null, [text('$stars')]),
          span([]),
          text('⑂'),
          span(styles: !loaded ? Styles(opacity: 0) : null, [text('$forks')])
        ])
      ])
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('.github-button', [
      css('&').styles(
        display: Display.flex,
        padding: Padding.symmetric(horizontal: 0.7.rem, vertical: 0.4.rem),
        radius: BorderRadius.circular(8.px),
        alignItems: AlignItems.center,
        gap: Gap(column: .5.rem),
        //color: textBlack,
        fontSize: 0.7.rem,
        textDecoration: TextDecoration.none,
      ),
      css('&:hover').styles(
          //backgroundColor: hoverOverlayColor,
          ),
      css('& *').styles(
        transition: Transition('opacity', duration: 200, curve: Curve.easeInOut),
      ),
      css('&:hover *').styles(
        raw: {'opacity': '1 !important'},
      ),
      css('& > i').styles(
        opacity: 0.9,
      ),
      css('div', [
        css('&').styles(
          display: Display.flex,
          flexDirection: FlexDirection.column,
        ),
        css('& > span:first-child').styles(
          margin: Margin.only(bottom: 2.px),
          opacity: 0.8,
          fontFamily: FontFamily.list([FontFamilies.monospace]),
        ),
        css('& > span:last-child').styles(
          display: Display.flex,
          opacity: 0.6,
          alignItems: AlignItems.center,
          gap: Gap(column: .3.em),
          fontSize: 0.9.em,
        ),
      ]),
    ]),
  ];
}

const githubIcon =
    r"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'><path d='M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12'/></svg>";
