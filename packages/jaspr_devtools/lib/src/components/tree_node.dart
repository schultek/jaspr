import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/devtools.dart';

import '../theme/devtools_theme.dart';

/// Renders a single node row in the component tree.
class TreeNodeRow extends StatelessComponent {
  const TreeNodeRow({
    required this.node,
    required this.isSelected,
    required this.isExpanded,
    required this.onSelect,
    required this.onToggleExpand,
    required this.searchQuery,
  });

  final InspectorNode node;
  final bool isSelected;
  final bool isExpanded;
  final void Function(int nodeId) onSelect;
  final void Function(int nodeId) onToggleExpand;
  final String searchQuery;

  @override
  Component build(BuildContext context) {
    final indent = node.depth * 16;
    final hasChildren = node.children.isNotEmpty;
    final matchesSearch =
        searchQuery.isNotEmpty && node.componentType.toLowerCase().contains(searchQuery.toLowerCase());

    return div(
      [
        // Expand/collapse arrow
        span(
          [Component.text(hasChildren ? (isExpanded ? '\u25BC' : '\u25B6') : '')],
          styles: Styles(raw: {
            'width': '16px',
            'text-align': 'center',
            'flex-shrink': '0',
            'color': DevToolsColors.textMuted,
            'font-size': '10px',
            'cursor': hasChildren ? 'pointer' : 'default',
            'user-select': 'none',
          }),
          events: hasChildren
              ? {
                  'click': (dynamic e) {
                    e.stopPropagation();
                    onToggleExpand(node.id);
                  },
                }
              : null,
        ),
        // Badge
        _buildBadge(),
        // Label
        span(
          [Component.text(node.displayLabel)],
          styles: Styles(raw: {
            'color': isSelected ? '#fff' : DevToolsColors.textPrimary,
            'overflow': 'hidden',
            'text-overflow': 'ellipsis',
          }),
        ),
        // Hydration badge
        if (node.wasHydrated != null) _buildHydrationBadge(),
      ],
      attributes: {'data-node-id': '${node.id}'},
      styles: Styles(raw: {
        'display': 'flex',
        'align-items': 'center',
        'padding': '2px 8px 2px ${indent}px',
        'cursor': 'pointer',
        'background': isSelected
            ? DevToolsColors.borderFocus
            : matchesSearch
                ? 'rgba(255, 152, 0, 0.15)'
                : 'transparent',
        'font-size': '12px',
        'line-height': '20px',
        'white-space': 'nowrap',
        'min-height': '22px',
      }),
      events: {
        'click': (dynamic e) => onSelect(node.id),
      },
    );
  }

  Component _buildBadge() {
    final String color;
    final String label;

    if (node.domTag != null) {
      color = DevToolsColors.badgeDom;
      label = 'DOM';
    } else if (node.textContent != null) {
      color = DevToolsColors.badgeText;
      label = 'TXT';
    } else if (node.isStateful) {
      color = DevToolsColors.badgeStateful;
      label = 'SFW';
    } else {
      color = DevToolsColors.badgeStateless;
      label = 'SLS';
    }

    return span(
      [Component.text(label)],
      styles: Styles(raw: {
        'background': color,
        'color': '#fff',
        'font-size': '9px',
        'font-weight': '600',
        'padding': '1px 4px',
        'border-radius': '3px',
        'margin-right': '6px',
        'flex-shrink': '0',
        'letter-spacing': '0.5px',
      }),
    );
  }

  Component _buildHydrationBadge() {
    final isSSR = node.wasHydrated!;
    return span(
      [Component.text(isSSR ? 'SSR' : 'CSR')],
      styles: Styles(raw: {
        'background': isSSR ? DevToolsColors.ssrBadge : DevToolsColors.csrBadge,
        'color': '#fff',
        'font-size': '9px',
        'font-weight': '600',
        'padding': '1px 3px',
        'border-radius': '3px',
        'margin-left': '6px',
        'flex-shrink': '0',
      }),
    );
  }
}
