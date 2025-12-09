/// @docImport 'html_parser.dart';
/// @docImport 'markdown_parser.dart';
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../page.dart';
import '../theme/theme.dart';

/// Parses a page into a list of nodes.
///
/// See also:
/// - [HtmlParser]
/// - [MarkdownParser]
abstract class PageParser {
  /// The pattern that is used to match the page path.
  /// It must match the entire path, not just the file suffix. Regexes are allowed.
  Pattern get pattern;

  /// Parses the given [page] into a list of nodes.
  ///
  /// A [Node] is a tree structure that represents the content of a page, similar to HTML.
  List<Node> parsePage(Page page);
}

extension PageBuilderExtension on Iterable<PageParser> {
  /// Parses the given [page] by selecting the matching parser and calling [PageParser.parsePage].
  List<Node> parsePage(Page page) {
    final parser = where((parser) => parser.pattern.matchAsPrefix(page.path) != null).firstOrNull;
    if (parser == null) {
      throw Exception('No parser found for page: ${page.path}');
    }
    return parser.parsePage(page);
  }
}

/// A tree-like object that represents the content of a page.
sealed class Node {
  const Node();
}

/// A node that represents simple text content.
class TextNode extends Node {
  const TextNode(this.text, {this.raw = false});

  final String text;
  final bool raw;

  @override
  String toString() => 'TextNode(text: $text, raw: $raw)';
}

/// A node that represents an element with a tag, attributes and children.
class ElementNode extends Node {
  const ElementNode(this.tag, this.attributes, this.children);

  final String tag;
  final Map<String, String> attributes;
  final List<Node>? children;

  @override
  String toString() {
    return 'ElementNode(tag: $tag, attributes: $attributes, children: $children)';
  }
}

/// A node that represents a component.
class ComponentNode extends Node {
  ComponentNode(this.component);

  final Component component;
}

extension NodeExtension on Node {
  /// Recursively gets the inner text of the node.
  String get innerText {
    return switch (this) {
      final TextNode n => n.text,
      final ElementNode n => n.children?.map((n) => n.innerText).join() ?? '',
      ComponentNode _ => '',
    };
  }
}

abstract class CustomComponent {
  /// Constructor for subclasses.
  const CustomComponent.base();

  /// Creates a custom component with the given pattern and builder.
  factory CustomComponent({
    required Pattern pattern,
    required CustomComponentBuilder builder,
    ThemeExtension<Object?>? theme,
  }) = _CustomComponent;

  /// Creates a component for the given node, or returns null.
  Component? create(Node node, NodesBuilder builder);

  /// An optional theme extension for this component.
  ///
  /// This will be merged into the [ContentTheme] of a page when the component
  /// is included in it's [PageConfig].
  ThemeExtension<Object?>? get theme => null;
}

/// A builder for creating components from a name, attributes, and child.
typedef CustomComponentBuilder = Component Function(String name, Map<String, String> attributes, Component? child);

/// Base class for creating components based on a name pattern.
abstract mixin class CustomComponentBase implements CustomComponent {
  const CustomComponentBase();

  /// The name pattern that the component matches.
  Pattern get pattern;

  /// Builds a component with the given name, attributes, and child.
  Component apply(String name, Map<String, String> attributes, Component? child);

  @override
  Component? create(Node node, NodesBuilder builder) {
    if (node is ElementNode && pattern.matchAsPrefix(node.tag) != null) {
      return apply(node.tag, node.attributes, node.children != null ? builder.build(node.children!) : null);
    }
    return null;
  }

  @override
  ThemeExtension<Object?>? get theme => null;
}

class _CustomComponent extends CustomComponentBase {
  const _CustomComponent({required this.pattern, required CustomComponentBuilder builder, this.theme})
    : _builder = builder;

  @override
  final Pattern pattern;
  final CustomComponentBuilder _builder;
  @override
  final ThemeExtension<Object?>? theme;

  @override
  Component apply(String name, Map<String, String> attributes, Component? child) {
    return _builder(name, attributes, child);
  }
}

/// Builds a list of nodes, including supported custom components.
///
/// Supported components are extracted from the page content and replaced with the corresponding component.
/// The correct syntax is determined by the [PageParser], but usually follows the pattern
/// `<ComponentName attribute="value">...</ComponentName>`.
class NodesBuilder {
  const NodesBuilder(this.components);

  final List<CustomComponent> components;

  /// Builds a component from the given nodes.
  Component build(List<Node>? nodes) {
    if (nodes == null || nodes.isEmpty) {
      return Component.fragment([]);
    }
    return Component.fragment(_buildNodes(nodes));
  }

  List<Component> _buildNodes(List<Node> nodes) {
    final result = <Component>[];
    outer:
    for (final node in nodes) {
      for (final component in components) {
        if (component.create(node, this) case final comp?) {
          result.add(comp);
          continue outer;
        }
      }
      if (node is TextNode) {
        if (node.raw) {
          result.add(RawText(node.text));
        } else {
          result.add(Component.text(node.text));
        }
      } else if (node is ElementNode) {
        result.add(
          Component.element(tag: node.tag, attributes: node.attributes, children: _buildNodes(node.children ?? [])),
        );
      } else if (node is ComponentNode) {
        result.add(node.component);
      }
    }
    return result;
  }
}
