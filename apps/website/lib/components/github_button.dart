import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../constants/theme.dart';
import 'icon.dart';

class GitHubButton extends StatefulComponent {
  const GitHubButton({super.key});

  @override
  State createState() => GitHubButtonState();
}

class GitHubButtonState extends State<GitHubButton> {
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
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final {"stargazers_count": int stars, "forks_count": int forks} = data;

      setState(() {
        this.stars = stars;
        this.forks = forks;
        loaded = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing GitHub data: $e\n${response.body}');
      }
      // noop
    }
  }

  @override
  Component build(BuildContext context) {
    return a(href: 'https://github.com/schultek/jaspr', target: .blank, classes: 'github-button', [
      Icon('custom-github', size: 1.2.rem),
      div([
        span([.text('schultek/jaspr')]),
        span([
          Icon('star'),
          span(styles: !loaded ? Styles(opacity: 0) : null, [.text('$stars')]),
          span([]),
          Icon('git-fork'),
          span(styles: !loaded ? Styles(opacity: 0) : null, [.text('$forks')]),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.github-button', [
      css('&').styles(
        display: .flex,
        padding: .symmetric(horizontal: 0.7.rem, vertical: 0.4.rem),
        radius: .circular(8.px),
        alignItems: .center,
        gap: .column(0.5.rem),
        color: textBlack,
        fontSize: 0.7.rem,
        textDecoration: .none,
      ),
      css('&:hover').styles(backgroundColor: hoverOverlayColor),
      css('& *').styles(
        transition: .new('opacity', duration: 200.ms, curve: .easeInOut),
      ),
      css('&:hover *').styles(raw: {'opacity': '1 !important'}),
      css('& > i').styles(opacity: 0.9),
      css('div', [
        css('&').styles(display: .flex, flexDirection: .column),
        css('& > span:first-child').styles(
          margin: .only(bottom: 2.px),
          opacity: 0.8,
          fontFamily: .list([FontFamilies.monospace]),
        ),
        css('& > span:last-child').styles(
          display: .flex,
          opacity: 0.6,
          alignItems: .center,
          gap: .column(0.3.em),
          fontSize: 0.9.em,
        ),
      ]),
    ]),
  ];
}
