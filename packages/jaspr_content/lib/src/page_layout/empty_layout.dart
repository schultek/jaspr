
import 'package:jaspr/server.dart';

import '../page.dart';
import 'page_layout.dart';

class EmptyLayout implements PageLayout {
  const EmptyLayout();

  @override
  String get name => 'empty';

  @override
  Component buildLayout(Page page, Component child) {
    return Document(
      title: switch ((page.data['title'], page.data['titleBase'])) {
        (String title, String base) => '$title | $base',
        (String title, _) => title,
        (_, String base) => base,
        _ => '',
      },
      lang: page.data['lang'] ?? 'en',
      body: main_([
        child,
      ]),
    );
  }
}
