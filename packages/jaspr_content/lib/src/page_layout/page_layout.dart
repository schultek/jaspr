import 'package:jaspr/jaspr.dart';

import '../page.dart';

abstract class PageLayout {
  String get name;

  Component buildLayout(Page page, Component child);
}
