import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/devtools.dart';

import '../theme/devtools_theme.dart';
import 'tree_node.dart';

/// The component tree panel — renders a scrollable list of tree nodes.
class TreeView extends StatefulComponent {
  const TreeView({
    required this.tree,
    required this.selectedId,
    required this.onSelect,
    required this.searchQuery,
  });

  final InspectorNode? tree;
  final int? selectedId;
  final void Function(int nodeId) onSelect;
  final String searchQuery;

  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  final Set<int> _collapsed = {};

  void _toggleExpand(int nodeId) {
    setState(() {
      if (_collapsed.contains(nodeId)) {
        _collapsed.remove(nodeId);
      } else {
        _collapsed.add(nodeId);
      }
    });
  }

  @override
  Component build(BuildContext context) {
    final tree = component.tree;
    if (tree == null) {
      return div(
        [Component.text('Waiting for app connection...')],
        styles: Styles(raw: {
          'display': 'flex',
          'align-items': 'center',
          'justify-content': 'center',
          'height': '100%',
          'color': DevToolsColors.textMuted,
          'font-size': '13px',
        }),
      );
    }

    final List<InspectorNode> flatNodes = <InspectorNode>[];
    _flattenTree(tree, flatNodes);

    return div(
      [
        for (final node in flatNodes)
          TreeNodeRow(
            node: node,
            isSelected: node.id == component.selectedId,
            isExpanded: !_collapsed.contains(node.id),
            onSelect: component.onSelect,
            onToggleExpand: _toggleExpand,
            searchQuery: component.searchQuery,
          ),
      ],
      styles: Styles(raw: {
        'flex': '1',
        'overflow-y': 'auto',
        'overflow-x': 'auto',
        'font-family': 'monospace',
        'background': DevToolsColors.background,
      }),
    );
  }

  /// Flattens the tree into a visible node list, respecting collapsed state.
  void _flattenTree(InspectorNode node, List<InspectorNode> result) {
    // Apply search filter: skip nodes that don't match and have no matching descendants.
    if (component.searchQuery.isNotEmpty && !_matchesSearch(node)) {
      return;
    }

    result.add(node);
    if (!_collapsed.contains(node.id)) {
      for (final child in node.children) {
        _flattenTree(child, result);
      }
    }
  }

  /// Returns true if this node or any descendant matches the search query.
  bool _matchesSearch(InspectorNode node) {
    if (node.componentType.toLowerCase().contains(component.searchQuery.toLowerCase())) {
      return true;
    }
    return node.children.any(_matchesSearch);
  }
}
