import 'package:jaspr/server.dart';

import '../page.dart';

abstract class PageBuilder {
  Set<String> get suffix;

  Future<Component> buildPage(Page page);
}
