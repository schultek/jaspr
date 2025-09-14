import 'package:jaspr/server.dart';
import 'package:markdown/markdown.dart' as md;

import '../jaspr_content.dart';

/// A component that parses and renders markdown content as a Jaspr component.
///
/// Supports defining a custom [md.Document] to use for parsing, as well as a list
/// of custom components that can be used in the markdown content.
///
/// The rendered markdown is wrapped in a [Content] section and has a default set of
/// typographic styles applied, which can be customized by providing a [ContentTheme]
/// somewhere up the component tree using `Content.wrapTheme(ContentTheme(...), child)`.
class Markdown extends StatelessComponent {
  Markdown({required this.content, this.document, this.components = const []});

  /// The markdown content to render.
  final String content;

  /// The markdown document to use.
  final md.Document? document;

  /// A list of custom components to use in the markdown.
  final List<CustomComponent> components;

  @override
  Component build(BuildContext context) {
    final markdownDocument =
        document ??
        md.Document(blockSyntaxes: MarkdownParser.defaultBlockSyntaxes, extensionSet: md.ExtensionSet.gitHubWeb);

    final markdownNodes = markdownDocument.parse(content);
    final nodes = MarkdownParser.buildNodes(markdownNodes);

    final child = NodesBuilder(components).build(nodes);
    return Content(child);
  }
}
