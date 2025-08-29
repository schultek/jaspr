import 'package:liquify/liquify.dart';

import '../page.dart';
import 'template_engine.dart';

/// A template engine that uses the Liquid templating language.
///
/// This engine uses the `liquid_engine` package to render Liquid templates.
class LiquidTemplateEngine implements TemplateEngine {
  const LiquidTemplateEngine({
    this.includesPath = 'content/_includes/',
    this.prepareTemplate,
  });

  final String includesPath;
  final void Function(Template, Page, List<Page> pages)? prepareTemplate;

  @override
  Future<void> render(Page page, List<Page> pages) async {
    final template = Template.parse(
      page.content,
      data: {...page.data, 'pages': pages.map((p) => p.data.page).toList()},
      root: _IncludeResolver(page, Uri(path: includesPath)),
    );

    prepareTemplate?.call(template, page, pages);

    page.apply(content: await template.renderAsync());
  }
}

class _IncludeResolver implements Root {
  _IncludeResolver(this.page, this._includesPath);

  final Page page;
  final Uri _includesPath;

  @override
  Source resolve(String relPath) {
    final file = _includesPath.resolve(relPath);
    final content = page.readPartialSync(file.path);
    return Source(file, content, this);
  }

  @override
  Future<Source> resolveAsync(String relPath) async {
    final file = _includesPath.resolve(relPath);
    final content = await page.readPartial(file.path);
    return Source(file, content, this);
  }
}
