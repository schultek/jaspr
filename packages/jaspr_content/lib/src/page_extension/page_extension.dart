import '../page.dart';
import '../page_parser/page_parser.dart';

abstract class PageExtension {
  List<Node> processNodes(List<Node> nodes, Page page);
}

