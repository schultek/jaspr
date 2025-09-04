import 'package:liquify/liquify.dart';
import 'package:path/path.dart' as path;

import '../page.dart';
import 'template_engine.dart';

/// A template engine that uses the Liquid templating language.
///
/// This engine uses the `liquify` package to render Liquid templates.
class LiquidTemplateEngine implements TemplateEngine {
  /// Creates a new template engine that
  /// uses `package:liquify` to parse and render Liquid templates.
  ///
  /// To find the source files referenced in usages of `include` and `render`,
  /// the engine resolves them relative to the specified [includesPath].
  /// The [includesPath] should be an absolute path or
  /// relative to the current working directory.
  /// By default, includes are found in the `content/_includes` directory.
  LiquidTemplateEngine({
    String? includesPath,
    this.prepareTemplate,
  }) : includesPath = includesPath ?? path.join('content', '_includes');

  final String includesPath;
  final void Function(Template, Page, List<Page> pages)? prepareTemplate;

  @override
  Future<void> render(Page page, List<Page> pages) async {
    final template = Template.parse(
      page.content,
      data: {...page.data, 'pages': pages.map((p) => p.data['page']).toList()},
      root: _IncludeResolver(page, includesPath),
    );

    prepareTemplate?.call(template, page, pages);

    page.apply(content: await template.renderAsync());
  }
}

class _IncludeResolver implements Root {
  _IncludeResolver(this.page, this._includesDirectoryPath);

  final Page page;
  final String _includesDirectoryPath;

  @override
  Source resolve(String relPath) {
    final filePath = path.join(_includesDirectoryPath, relPath);
    final content = page.readPartialSync(filePath);
    return Source(Uri.file(filePath), content, this);
  }

  @override
  Future<Source> resolveAsync(String relPath) async {
    final filePath = path.join(_includesDirectoryPath, relPath);
    final content = await page.readPartial(filePath);
    return Source(Uri.file(filePath), content, this);
  }
}
