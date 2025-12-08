import 'package:jaspr/server.dart';

import '../page.dart';
import 'secondary_output.dart';

/// Outputs a secondary 'index.html.md' file for a markdown page containing its unparsed content.
class MarkdownOutput extends SecondaryOutput {
  /// A function that creates a Markdown header for the
  /// passed in [Page].
  final String Function(Page)? createHeader;

  /// Creates a [SecondaryOutput] that outputs a secondary `.index.html.md` file for
  /// each Markdown page containing its unparsed content.
  ///
  /// A custom header can be added to the generated Markdown file based on
  /// each individual page by specifying a [createHeader] callback function.
  MarkdownOutput({this.createHeader});

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
        if (createHeader case final createHeader?) {
          final headerForPage = createHeader(page);
          pageContent.writeln(headerForPage);
        }

        pageContent.writeln(page.content);

        context.setHeader('Content-Type', 'text/markdown');
        context.setStatusCode(200, responseBody: pageContent.toString());
        return Component.text('');
      },
    );
  }
}
