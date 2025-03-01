import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' as html;
import 'package:jaspr/server.dart' hide ComponentBuilder;

import '../page.dart';
import 'page_parser.dart';

class HtmlParser implements PageParser {
  HtmlParser();

  @override
  Set<String> get suffix => {'.html', '.htm'};

  @override
  List<Node> parsePage(Page page) {
    final document = html.parse(page.content);
    return _buildNodes(document.nodes);
  }

  List<Node> _buildNodes(Iterable<html.Node> htmlNodes) {
    final nodes = <Node>[];
    for (final node in htmlNodes) {
      if (node is html.Text) {
        nodes.add(TextNode(node.text));
      } else if (node is html.Element) {
        final children = _buildNodes(node.nodes);
        nodes.add(ElementNode(node.localName ?? '', node.attributes.cast(), children));
      }
    }
    return nodes;
  }
  
}
