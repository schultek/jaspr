import 'package:jaspr/server.dart';

import '../page.dart';

/// Parses a page into a list of nodes.
abstract class PageParser {

  /// The pattern that is used to match the page name (usually the file name).
  /// It must match the entire name, not just the file suffix. Regexes are allowed.
  Pattern get pattern;

  /// Parses the given [page] into a list of nodes.
  /// 
  /// A [Node] is a tree structure that represents the content of a page, similar to HTML.
  List<Node> parsePage(Page page);
}

extension PageBuilderExtension on Iterable<PageParser> {
  /// Parses the given [page] by selecting the matching parser and calling [PageParser.parsePage].
  List<Node> parsePage(Page page) {
    final parser = where((parser) => parser.pattern.matchAsPrefix(page.name) != null).firstOrNull;
    if (parser == null) {
      throw Exception('No parser found for page: ${page.name}');
    }
    return parser.parsePage(page);
  }
}

/// A tree-like object that represents the content of a page.
sealed class Node {
  const Node();

  T accept<T>(NodeVisitor<T> visitor);
}

/// A node that represents simple text content.
class TextNode extends Node {
 const TextNode(this.text, {this.raw = false});

  final String text;
  final bool raw;

  @override
  T accept<T>(NodeVisitor<T> visitor) {
    return visitor.visitTextNode(this);
  }
}

/// A node that represents an element with a tag, attributes and children.
class ElementNode extends Node {
  const ElementNode(this.tag, this.attributes, this.children);

  final String tag;
  final Map<String, String> attributes;
  final List<Node>? children;

  @override
  T accept<T>(NodeVisitor<T> visitor) {
    return visitor.visitElementNode(this);
  }
}

/// A node that represents a component.
class ComponentNode extends Node {
  ComponentNode(this.component);

  final Component component;

  @override
  T accept<T>(NodeVisitor<T> visitor) {
    return visitor.visitComponentNode(this);
  }
}

extension NodeExtension on Node {
  /// Recursively gets the inner text of the node.
  String get innerText {
    return switch (this) {
      TextNode n => n.text,
      ElementNode n => n.children?.map((n) => n.innerText).join() ?? '',
      ComponentNode _ => '',
    };
  }
}

extension NodesExtension on Iterable<Node> {
  Component build() {
    return Fragment(children: _buildNodes());
  }

  List<Component> _buildNodes() {
    final components = <Component>[];
    for (final node in this) {
      if (node is TextNode) {
        if (node.raw) {
          components.add(raw(node.text));
        } else {
          components.add(text(node.text));
        }
      } else if (node is ElementNode) {
        components.add(DomComponent(
          tag: node.tag,
          attributes: node.attributes,
          child: node.children?.build(),
        ));
      } else if (node is ComponentNode) {
        components.add(node.component);
      }
    }
    return components;
  }
}

abstract class NodeVisitor<T> {
  T visitTextNode(TextNode node);
  T visitElementNode(ElementNode node);
  T visitComponentNode(ComponentNode node);
}

abstract class RecursiveNodeVisitor implements NodeVisitor<void> {
  @override
  void visitElementNode(ElementNode node) {
    if (node.children case final children?) {
      for (final child in children) {
        child.accept(this);
      }
    }
  }
}
