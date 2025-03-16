import 'package:jaspr/server.dart';
import 'package:jaspr_content/components/callout.dart';
import 'package:jaspr_content/jaspr_content.dart';

void main() {
  Jaspr.initializeApp();

  runApp(ContentApp(
    templateEngine: MustacheTemplateEngine(),
    parsers: [
      HtmlParser(),
      MarkdownParser(),
    ],
    extensions: [
      // Enables using custom components like '<Info>Hello</Info>'.
      ComponentsExtension([
        Callout.factory,
      ]),
    ],
    layouts: [
      EmptyLayout(),
    ],
  ));
}