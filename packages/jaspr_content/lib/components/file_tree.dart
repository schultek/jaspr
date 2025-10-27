import 'package:jaspr/jaspr.dart';

import '../jaspr_content.dart';

/// A file tree component for displaying a directory structure.
class FileTree implements CustomComponent {
  const FileTree();

  @override
  Component? create(Node node, NodesBuilder builder) {
    if (node is ElementNode && node.tag == 'FileTree') {
      final child = buildFileTree(node.children ?? [], builder);
      return div(classes: 'file-tree', [child]);
    }
    return null;
  }

  Component buildFileTree(List<Node> nodes, NodesBuilder builder) {
    if (nodes case [ElementNode(tag: 'ul', :final children)]) {
      List<Component> items = [];

      for (final child in children ?? <Node>[]) {
        items.add(buildFileTreeItem(child, builder));
      }

      return ul(items);
    }

    throw Exception('Invalid FileTree structure, must contain a single list.');
  }

  Component buildFileTreeItem(Node node, NodesBuilder builder) {
    if (node case ElementNode(tag: 'li', :final children)) {
      if (children case [...final inner, ElementNode(tag: 'ul', :final children)]) {
        List<Component> subItems = [];

        for (final subChild in children ?? <Node>[]) {
          subItems.add(buildFileTreeItem(subChild, builder));
        }

        return li(classes: 'directory', [
          details([
            summary([
              buildFileTreeEntry(inner, builder),
            ]),
            ul(subItems),
          ]),
        ]);
      }

      return li(classes: 'file', [buildFileTreeEntry(children ?? <Node>[], builder)]);
    }

    throw Exception('Invalid FileTree item structure, must be a list item.');
  }

  Component buildFileTreeEntry(List<Node> nodes, NodesBuilder builder) {
    if (nodes case [ElementNode(tag: 'strong', :final children), ...final rest]) {
      return span(classes: 'tree-entry', [
        span(classes: 'highlight', [
          builder.build(children ?? <Node>[]),
        ]),
        if (rest.isNotEmpty)
          span(classes: 'comment', [
            builder.build(rest),
          ]),
      ]);
    }

    if (nodes case [TextNode(text: final t), ...final rest] when t.contains(' ')) {
      final parts = t.split(' ');
      return span(classes: 'tree-entry', [
        span([
          text(parts[0].trim()),
        ]),
        span(classes: 'comment', [
          text(parts.sublist(1).join(' ').trim()),
          if (rest.isNotEmpty) builder.build(rest),
        ]),
      ]);
    }

    return span(classes: 'tree-entry', [builder.build(nodes)]);
  }
}
