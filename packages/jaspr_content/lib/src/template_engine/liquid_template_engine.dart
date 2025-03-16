import 'package:liquid_engine/liquid_engine.dart';
// ignore: implementation_imports
import 'package:liquid_engine/src/buildin_tags/include.dart';

import '../page.dart';
import 'template_engine.dart';

void _defaultPrepareContext(Context context, Page page) {
  context.tags.addAll({
    'render': Include.factory,
  });
}

/// A template engine that uses the Liquid templating language.
/// 
/// This engine uses the `liquid_engine` package to render Liquid templates.
class LiquidTemplateEngine implements TemplateEngine {
  const LiquidTemplateEngine({
    this.includesPath = 'content/_includes/',
    this.prepareContext = _defaultPrepareContext,
  });

  final void Function(Context, Page) prepareContext;
  final String includesPath;

  @override
  Future<void> render(Page page) async {
    var context = Context.create();
    context.variables.addAll(page.data);
    prepareContext(context, page);

    final template = Template.parse(
      context,
      Source(null, page.content, _IncludeResolver(page, Uri(path: includesPath))),
    );

    page.apply(content: await template.render(context));
  }
}

class _IncludeResolver implements Root {
  _IncludeResolver(this.page, this._includesPath);

  final Page page;
  final Uri _includesPath;

  @override
  Future<Source> resolve(String relPath) async {
    final file = _includesPath.resolve(relPath);
    final content = await page.readPartial(file.path);
    return Source(file, content, this);
  }
}
