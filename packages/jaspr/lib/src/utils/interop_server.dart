import '../../jaspr_server.dart';

extension NativeDomNode on RenderElement {
  dynamic get nativeElement => getData();
}
