import '../../jaspr_server.dart';

extension NativeDomNode on DomNode {
  dynamic get nativeElement => data;
}
