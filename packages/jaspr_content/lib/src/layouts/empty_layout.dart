import 'package:jaspr/server.dart';

import '../page.dart';
import 'page_layout.dart';

/// An empty layout with no additional elements.
///
/// The page content is rendered as is directly in the body.
class EmptyLayout extends PageLayoutBase {
  const EmptyLayout();

  @override
  String get name => 'empty';

  @override
  Component buildBody(Page page, Component child) {
    return main_([child]);
  }
}
