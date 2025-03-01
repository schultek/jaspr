import 'package:jaspr/server.dart';

import '../page.dart';

abstract class PageParser {
  Set<String> get suffix;

  List<Node> parsePage(Page page);
}

extension PageBuilderExtension on Iterable<PageParser> {
  List<Node> parsePage(Page page) {
    final parser = where((parser) => parser.suffix.any((s) => page.path.endsWith(s))).firstOrNull;
    if (parser == null) {
      throw Exception('No parser found for page: $path');
    }
    return parser.parsePage(page);
  }
}

sealed class Node {
  Node();

  T accept<T>(NodeVisitor<T> visitor);
}

class TextNode extends Node {
  TextNode(this.text, {this.raw = false});

  final String text;
  final bool raw;

  @override
  T accept<T>(NodeVisitor<T> visitor) {
    return visitor.visitTextNode(this);
  }
}

class ElementNode extends Node {
  ElementNode(this.tag, this.attributes, this.children);

  final String tag;
  final Map<String, String> attributes;
  final List<Node>? children;

  @override
  T accept<T>(NodeVisitor<T> visitor) {
    return visitor.visitElementNode(this);
  }
}

class ComponentNode extends Node {
  ComponentNode(this.component);

  final Component component;

  @override
  T accept<T>(NodeVisitor<T> visitor) {
    return visitor.visitComponentNode(this);
  }
}

extension NodeExtension on Node {
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
