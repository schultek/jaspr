import 'package:jaspr/server.dart' hide ComponentBuilder;

import '../page.dart';

import 'page_builder.dart';

class HtmlPageBuilder implements PageBuilder {
  HtmlPageBuilder();

  @override
  Set<String> get suffix => {'.html'};

  @override
  Future<Component> buildPage(Page page) async {
    page.parseFrontmatter();
    await page.renderTemplate();

    Component child = RawText(page.content);

    return page.buildLayout(child);
  }
}
