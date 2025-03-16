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
    final template = _buildTemplate(page, page.content);
    page.apply(content: template.renderString(prepareValues(page)));
  }

  Template _buildTemplate(Page page, String content) {
    return Template(
      content,
      partialResolver: (String name) {
        final path = Uri.parse(partialsRoot).resolve(name);
        return _buildTemplate(page, page.readPartialSync(path));
      },
      delimiters: delimiters,
    );
  }
}
