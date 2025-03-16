import '../page.dart';

/// A template engine for preprocessing a page's content.
abstract class TemplateEngine {
  /// Renders the given [page]'s content. The content is modified in place.
  Future<void> render(Page page);
}
