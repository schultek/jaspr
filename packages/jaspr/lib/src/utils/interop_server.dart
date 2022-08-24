import '../../server.dart';

extension NativeDomNode on RenderElement {
  dynamic get nativeElement => getData();
}
