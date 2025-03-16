import 'package:mustache_template/mustache_template.dart';
import '../page.dart';
import 'template_engine.dart';

dynamic _defaultPrepareValues(Page page) {
  return page.data;
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
  final dynamic Function(Page page) prepareValues;

  @override
  Future<void> render(Page page) async {
    final root = Uri.parse(partialsRoot);
    final template = _buildTemplate(page, page.content, root);
    page.apply(content: template.renderString(prepareValues(page)));
  }

  Template _buildTemplate(Page page, String content, Uri root) {
    return Template(
      content,
      partialResolver: (String name) {
        final path = root.resolve(name).path;
        return _buildTemplate(page, page.readPartialSync(path), root);
      },
      delimiters: delimiters,
    );
  }
}
