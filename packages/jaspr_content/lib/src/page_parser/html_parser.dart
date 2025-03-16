import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' as html;

import '../page.dart';
import 'page_parser.dart';

/// A parser for HTML content.
class HtmlParser implements PageParser {
  const HtmlParser();

  @override
  Pattern get pattern => RegExp(r'.*\.html');

  @override
  List<Node> parsePage(Page page) {
    final document = html.parse(page.content);
    return buildNodes(document.nodes);
  }

  static List<Node> buildNodes(Iterable<html.Node> htmlNodes) {
    final nodes = <Node>[];
    for (final node in htmlNodes) {
      if (node is html.Text) {
        nodes.add(TextNode(node.text));
      } else if (node is html.Element) {
        final children = buildNodes(node.nodes);
        nodes.add(ElementNode(node.localName ?? '', node.attributes.cast(), children));
      }
    }
    return nodes;
  }
  
}
