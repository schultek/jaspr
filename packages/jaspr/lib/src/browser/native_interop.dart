import 'dart:html';

import '../framework/framework.dart';
import 'dom_renderer.dart';

extension NativeDomNode on RenderElement {
  Node? get nativeElement => data.node;
}
