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
      builder: (context) sync* {
        context.setHeader('Content-Type', 'text/markdown');
        context.setStatusCode(200, responseBody: page.content);
      },
    );
  }
}
