import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' as html;
// ignore: implementation_imports
import 'package:html/src/tokenizer.dart' as html;

import '../page.dart';
import 'page_parser.dart';

/// A parser for HTML content.
class HtmlParser implements PageParser {
  const HtmlParser();

  @override
  Pattern get pattern => RegExp(r'.*\.html$');

  @override
  List<Node> parsePage(Page page) {
    final tokenizer = html.HtmlTokenizer(page.content, lowercaseElementName: false);
    final fragment = html.parseFragment(tokenizer);
    return buildNodes(fragment.nodes);
  }

  static List<Node> buildNodes(Iterable<html.Node> htmlNodes) {
    final nodes = <Node>[];
    for (final node in htmlNodes) {
      if (node is html.Text) {
        nodes.add(TextNode(node.text));
      } else if (node is html.Element) {
        final children = buildNodes(node.nodes);
        nodes.add(ElementNode(node.localName ?? '', node.attributes.cast(), children));
      } else if (node is html.Comment) {
        nodes.add(TextNode('<!--${node.data}-->', raw: true));
      }
    }
    return nodes;
  }
}
