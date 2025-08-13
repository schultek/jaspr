import 'package:mustache_template/mustache_template.dart';
import '../page.dart';
import 'template_engine.dart';

Map<String, Object?> _defaultPrepareValues(Page page, List<Page> pages) {
  return {...page.data}..putIfAbsent('pages', () => pages.map((p) => p.data.page).toList());
}

/// A template engine that uses the Mustache templating language.
///
/// This engine uses the `mustache_template` package to render Mustache templates.
class MustacheTemplateEngine implements TemplateEngine {
  const MustacheTemplateEngine({
    this.delimiters = '{{ }}',
    this.partialsRoot = 'content/_partials/',
    this.prepareValues = _defaultPrepareValues,
  });

  final String delimiters;
  final String partialsRoot;
  final Object? Function(Page page, List<Page> pages) prepareValues;

  @override
  Future<void> render(Page page, List<Page> pages) async {
    final root = Uri.parse(partialsRoot);
    final template = _buildTemplate(page, page.content, root);

    page.apply(content: template.renderString(prepareValues(page, pages)));
  }

  Template _buildTemplate(Page page, String content, Uri root) {
    return Template(
      content,
      lenient: true,
      partialResolver: (String name) {
        final path = root.resolve(name).path;
        return _buildTemplate(page, page.readPartialSync(path), root);
      },
      delimiters: delimiters,
    );
  }
}
