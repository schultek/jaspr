import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jaspr/jaspr.dart';

@Deprecated('Migrate to GitHubButton instead.')
typedef GithubButton = GitHubButton;

/// A button that links to a GitHub repository and shows stars and forks.
@client
final class GitHubButton extends StatefulComponent {
  /// Create a new [GitHubButton] component that links to the specified GitHub [repo]
  /// and shows the amount of stars and forks it has.
  const GitHubButton({
    required this.repo,
    super.key,
  });

  /// The ID of the GitHub repository,
  /// in the form `<organization or user name>/<repository name>`.
  final String repo;

  @override
  State<GitHubButton> createState() => _GitHubButtonState();

  @css
  static List<StyleRule> get styles => [
        css('.github-button', [
          css('&').styles(
            display: Display.flex,
            padding: Padding.symmetric(horizontal: 0.7.rem, vertical: 0.4.rem),
            radius: BorderRadius.circular(8.px),
            alignItems: AlignItems.center,
            gap: Gap(column: .5.rem),
            fontSize: 0.7.rem,
            textDecoration: TextDecoration.none,
            lineHeight: 1.2.em,
          ),
          css('&:hover').styles(
            backgroundColor: Color('color-mix(in srgb, currentColor 5%, transparent)'),
          ),
          css('& *').styles(
            transition: Transition('opacity', duration: 200, curve: Curve.easeInOut),
          ),
          css('&:hover *').styles(
            raw: {'opacity': '1 !important'},
          ),
          css('.github-icon').styles(
            width: 1.2.rem,
          ),
          css('.github-info', [
            css('&').styles(
              display: Display.flex,
              flexDirection: FlexDirection.column,
            ),
            css('& > span:first-child').styles(
              margin: Margin.only(bottom: 2.px),
              opacity: 0.9,
              fontFamily: FontFamily.list([FontFamilies.monospace]),
            ),
            css('& > span:last-child', [
              css('&').styles(
                display: Display.flex,
                opacity: 0.7,
                alignItems: AlignItems.center,
                gap: Gap(column: .3.em),
                fontSize: 0.9.em,
                fontWeight: FontWeight.w800,
              ),
              css('span').styles(fontWeight: FontWeight.w500)
            ]),
          ]),
        ]),
      ];
}

class _GitHubButtonState extends State<GitHubButton> with PreloadStateMixin<GitHubButton> {
  int? _stars;
  int? _forks;

  bool get loaded => _stars != null;

  @override
  Future<void> preloadState() async {
    if (!kGenerateMode && kReleaseMode) {
      await loadRepositoryData();
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
    final response = await http.get(Uri.https('api.github.com', '/repos/${component.repo}'));
    if (response.statusCode != 200) {
      return;
    }
    final data = jsonDecode(response.body) as Map<String, Object?>;
    final {'stargazers_count': stars as int, 'forks_count': forks as int} = data;

    _stars = stars;
    _forks = forks;
  }

  @override
  Iterable<Component> build(BuildContext _) sync* {
    yield a(href: 'https://github.com/${component.repo}', target: Target.blank, classes: 'github-button not-content', [
      div(classes: 'github-icon', const [
        _GitHubIcon(),
      ]),
      div(classes: 'github-info', [
        span([text(component.repo)]),
        span([
          text('★'),
          span(styles: !loaded ? const Styles(opacity: 0) : null, [text('${_stars ?? 9999}')]),
          span([]),
          text('⑂'),
          span(styles: !loaded ? const Styles(opacity: 0) : null, [text('${_forks ?? 99}')])
        ])
      ])
    ]);
  }
}

class _GitHubIcon extends StatelessComponent {
  const _GitHubIcon();

  @override
  Iterable<Component> build(BuildContext _) sync* {
    yield svg(viewBox: '0 0 24 24', attributes: {
      'fill': 'currentColor'
    }, [
      path(
        d: r'M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.0'
            '15-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.2'
            '05.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-'
            '1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1'
            '.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.8'
            '4 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 '
            '.315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12',
        [],
      ),
    ]);
  }
}
