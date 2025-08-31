import 'dart:io';

import 'package:jaspr/jaspr.dart';
import 'package:markdown/markdown.dart';

import '../constants/theme.dart';
import '../layout/footer.dart';
import '../layout/header.dart';

class MarkdownPage extends StatelessComponent {
  const MarkdownPage(this.filename, {super.key});

  final String filename;

  @override
  Component build(BuildContext context) {
    final file = File(filename);
    final content = file.readAsStringSync();
    final html = markdownToHtml(content);

    return fragment([
      Header(showHome: true),
      main_(classes: 'markdown-content', [
        raw(html),
      ]),
      Footer(),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
        css('.markdown-content', [
          css('&').styles(
            minHeight: 50.vh,
            padding: Padding.only(top: 8.rem, left: contentPadding, right: contentPadding, bottom: 4.rem),
          ),
          css('h3').styles(margin: Margin.only(top: 3.rem)),
        ]),
      ];
}
