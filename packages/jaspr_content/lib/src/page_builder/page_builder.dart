import 'package:jaspr/server.dart';

import '../page.dart';

abstract class PageBuilder {
  Set<String> get suffix;

  Future<Component> buildPage(Page page);
}

extension PageBuilderExtension on Iterable<PageBuilder> {
  Future<Component> buildPage(Page page) {
    final builder = where((builder) => builder.suffix.any((s) => page.path.endsWith(s))).firstOrNull;
    if (builder == null) {
      throw Exception('No suffix builder found for path: $path');
    }

    return builder.buildPage(page);
  }
}