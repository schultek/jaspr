import 'package:jaspr/jaspr.dart';

import '../page.dart';
import '../page_parser/page_parser.dart';
import 'page_extension.dart';

typedef ComponentCallback = Component Function(Map<String, String> attributes, Component? child);

class ComponentsExtension implements PageExtension {
  ComponentsExtension(this.components);

  final Map<String, ComponentCallback> components;

  @override
  List<Node> processNodes(List<Node> nodes, Page page) {
    return _processNodes(nodes);
  }

  List<Node> _processNodes(List<Node> nodes) {
    final processed = <Node>[];
    for (final node in nodes) {
      processed.add(switch (node) {
        ElementNode n => _processNode(n),
        _ => node,
      });
    }
    return processed;
  }

  Node _processNode(ElementNode node) {
    var builder = components[node.tag];
    if (builder != null) {
      return ComponentNode(builder(node.attributes, node.children?.build()));
    }
    return ElementNode(
      node.tag,
      node.attributes,
      node.children != null ? _processNodes(node.children!) : null,
    );
  }
}
