import 'package:jaspr/jaspr.dart';

import '../page.dart';
import '../page_parser/page_parser.dart';
import 'page_extension.dart';

/// An extension that renders custom components to the page.
/// 
/// Supported components are extracted from the page content and replaced with the corresponding component.
/// The correct syntax is determined by the [PageParser], but usually follows the pattern 
/// `<ComponentName attribute="value">...</ComponentName>`.
class ComponentsExtension implements PageExtension {
  /// Creates a [ComponentsExtension] with the given component factories.
  /// 
  /// The factories are used to create the components based on their name and attributes.
  const ComponentsExtension(this.factories);

  final List<ComponentFactory> factories;

  @override
  List<Node> apply(Page page, List<Node> nodes) {
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
    final factory = factories.where((c) => c.pattern.matchAsPrefix(node.tag) != null).firstOrNull;
    final children = node.children != null ? _processNodes(node.children!) : null;
    if (factory != null) {
      return ComponentNode(factory.build(node.tag, node.attributes, children?.build()));
    }
    // Ignore unspecified components.
    if (node.tag.startsWith(RegExp(r'[A-Z]'))) {
      print("[Warning] Ignoring unspecified component: ${node.tag}");
      return ComponentNode(children != null ? children.build() : Fragment(children: []));
    }
    return ElementNode(node.tag, node.attributes, children);
  }
}

/// A factory for creating components based on a name pattern.
abstract class ComponentFactory {
  /// Creates a component factory with the given pattern and builder.
  const factory ComponentFactory({
    required Pattern pattern,
    required ComponentBuilder build,
  }) = _ComponentFactory;

  /// The name pattern that the factory matches.
  Pattern get pattern;

  /// Builds a component with the given name, attributes, and child.
  Component build(String name, Map<String, String> attributes, Component? child);
}

/// A builder for creating components from a name, attributes, and child.
typedef ComponentBuilder = Component Function(String name, Map<String, String> attributes, Component? child);

class _ComponentFactory implements ComponentFactory {
  const _ComponentFactory({
    required this.pattern,
    required ComponentBuilder build,
  }) : _build = build;

  @override
  final Pattern pattern;
  final ComponentBuilder _build;

  @override
  Component build(String name, Map<String, String> attributes, Component? child) {
    return _build(name, attributes, child);
  }
}
