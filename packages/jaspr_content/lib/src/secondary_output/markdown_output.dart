import 'package:jaspr/server.dart';

import '../page.dart';
import 'secondary_output.dart';

/// Outputs a secondary 'index.html.md' file for a markdown page containing its unparsed content.
class MarkdownOutput extends SecondaryOutput {
  @override
  final Pattern pattern = RegExp(r'.*\.mdx?');

  @override
  String createRoute(String route) {
    if (route.endsWith('/')) {
      route += 'index.html';
    } else if (!route.split('/').last.contains('.')) {
      route += '/index.html';
    }
    return route += '.md';
  }

  @override
  Component build(Page page) {
    return Builder(
      builder: (context) {
        final pageContent = StringBuffer();
        if (page.data.page['title'] case final String title when title.isNotEmpty) {
          pageContent.writeln('# $title');

          if (page.data.page['description'] case final String description when description.isNotEmpty) {
            pageContent.writeln();
            pageContent.writeln('> $description');
          }

          pageContent.writeln();
        }

        pageContent.write(page.content);

        context.setHeader('Content-Type', 'text/markdown');
        context.setStatusCode(200, responseBody: pageContent.toString());
        return Component.text('');
      },
    );
  }
}
