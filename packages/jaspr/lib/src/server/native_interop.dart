import '../framework/framework.dart';

extension NativeDomNode on RenderElement {
  dynamic get nativeElement => getData();
}
