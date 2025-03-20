
/// @docImport 'liquid_template_engine.dart';
/// @docImport 'mustache_template_engine.dart';
library;

import '../page.dart';

/// A template engine for preprocessing a page's content.
/// 
/// See also:
/// - [LiquidTemplateEngine]
/// - [MustacheTemplateEngine]
abstract class TemplateEngine {
  /// Renders the given [page]'s content. The content is modified in place.
  Future<void> render(Page page, List<Page> pages);
}
