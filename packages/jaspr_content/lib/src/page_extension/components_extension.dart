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
    final builder = components[node.tag];
    final children = node.children != null ? _processNodes(node.children!) : null;
    if (builder != null) {
      return ComponentNode(builder(node.attributes, children?.build()));
    }
    // Ignore unspecified components.
    if (node.tag.startsWith(RegExp(r'[A-Z]'))) {
      return ComponentNode(children != null ? children.build() : Fragment(children: []));
    }
    return ElementNode(
      node.tag,
      node.attributes,
      children,
    );
  }
}
