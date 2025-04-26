/// @docImport 'heading_anchor_extension.dart';
/// @docImport 'table_of_contents_extension.dart';
library;

import '../page.dart';
import '../page_parser/page_parser.dart';

/// An extension that can post-process a page and its parsed nodes.
///
/// See also:
/// - [HeadingAnchorExtension]
/// - [TableOfContentsExtension]
abstract class PageExtension {
  /// Applies the extension to the given [Page] and parsed [Node]s.
  ///
  /// The page may be modified in place while the nodes should be returned as a new list.
  ///
  /// As the page is already parsed, modifying its content or data may not have any effect. Though it can be used to
  /// provide additional context to later applied extensions or layouts.
  List<Node> apply(Page page, List<Node> nodes);
}
