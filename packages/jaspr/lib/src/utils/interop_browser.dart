import '../../jaspr_browser.dart';

extension NativeDomNode on RenderElement {
  dynamic get nativeElement => data.node;
}
