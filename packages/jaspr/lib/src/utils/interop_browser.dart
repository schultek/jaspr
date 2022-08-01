import 'dart:html';

import '../../jaspr_browser.dart';

extension NativeDomNode on DomNode {
  dynamic get nativeElement => data.node;
}
