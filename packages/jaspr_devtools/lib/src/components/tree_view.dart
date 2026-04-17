import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../models/tree_state.dart';
import '../styles/theme.dart';

class TreeView extends StatelessComponent {
  const TreeView({
    required this.root,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final DiagnosticsNode? root;
  final DiagnosticsNode? selected;
  final ValueChanged<DiagnosticsNode> onSelected;

  @override
  Component build(BuildContext context) {
    if (root == null) {
      return div(classes: 'tree-empty', [.text('No component tree available.')]);
    }

    return div(classes: 'tree-view', [
      TreeItem(
        node: root!,
        selected: selected,
        onSelected: onSelected,
        depth: 1,
        depthLimit: TreeItemState.maxDepthLimit,
      ),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.tree-view').styles(
      width: .fitContent,
      minWidth: 100.percent,
      padding: .symmetric(vertical: ThemeSpacing.s4),
      fontFamily: .list([FontFamily('JetBrains Mono'), FontFamilies.monospace]),
      fontSize: 0.875.rem,
    ),
    css('.tree-empty').styles(
      padding: .all(ThemeSpacing.s8),
      textAlign: .center,
      color: ThemeColors.onSurfaceVariant,
      fontStyle: FontStyle.italic,
    ),
  ];
}

class TreeItem extends StatefulComponent {
  const TreeItem({
    required this.node,
    required this.selected,
    required this.onSelected,
    required this.depth,
    required this.depthLimit,
    super.key,
  });

  final DiagnosticsNode node;
  final DiagnosticsNode? selected;
  final ValueChanged<DiagnosticsNode> onSelected;
  final int depth;
  final int depthLimit;

  @override
  State<TreeItem> createState() => TreeItemState();
}

class TreeItemState extends State<TreeItem> {
  bool expanded = true;
  bool showMore = false;

  static const maxDepthLimit = 20;
  static const inset = 16;

  @override
  Component build(BuildContext context) {
    final isSelected = component.selected == component.node;
    final hasChildren = component.node.children?.isNotEmpty ?? false;

    final type = component.node.properties?.get('type')?.value.toString();

    final name = switch (type) {
      'DomComponent' =>
        component.node.properties?.get('component')?.properties?.get('tag')?.value.toString() ?? 'DomComponent',
      _ => type ?? component.node.name,
    };

    final environment = component.node.properties?.where((p) => p.name == 'environment').firstOrNull?.value?.toString();
    final envClass = environment == 'client'
        ? 'client'
        : environment == 'server'
        ? 'server'
        : '';

    return div(classes: 'tree-item-container', [
      div(
        classes: 'tree-item ${isSelected ? 'selected' : ''} $envClass',
        events: {
          'click': (e) {
            e.stopPropagation();
            component.onSelected(component.node);
          },
        },
        styles: Styles(padding: .only(left: (component.depth * inset).px)),
        [
          if (hasChildren)
            span(
              classes: 'toggle ${expanded ? 'expanded' : ''}',
              events: {
                'click': (e) {
                  e.stopPropagation();
                  setState(() => expanded = !expanded);
                },
              },
              [],
            )
          else
            span(classes: 'spacer', []),

          span(classes: 'tag-open', [.text('<')]),
          span(classes: 'name', [.text(name)]),
          span(classes: 'tag-close', [.text(' />')]),
        ],
      ),
      if (hasChildren && expanded)
        if (component.depthLimit > 0 || showMore)
          .fragment([
            for (final child in component.node.children!)
              TreeItem(
                node: child,
                selected: component.selected,
                onSelected: component.onSelected,
                depth: component.depth + 1,
                depthLimit: (showMore ? maxDepthLimit : component.depthLimit) - (component.node.children?.length ?? 1),
              ),
          ])
        else
          div(
            classes: 'tree-item depth-limit',
            events: {
              'click': (e) {
                e.stopPropagation();
                setState(() => showMore = true);
              },
            },
            styles: Styles(padding: .only(left: ((component.depth + 2) * inset).px)),
            [.text('...')],
          ),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.tree-item').styles(
      display: .flex,
      alignItems: .center,
      padding: .symmetric(vertical: 2.px, horizontal: ThemeSpacing.s2),
      cursor: .pointer,
      transition: Transition('all', duration: 100.ms),
      whiteSpace: .noWrap,
    ),
    css('.tree-item:hover').styles(
      backgroundColor: ThemeColors.surfaceContainerHighest,
    ),
    css('.tree-item.selected').styles(
      backgroundColor: ThemeColors.surfaceContainerHigh,
      border: Border.only(
        left: BorderSide(width: 2.px, color: ThemeColors.primary),
      ),
    ),
    css('.toggle').styles(
      width: 12.px,
      height: 12.px,
      display: .inlineBlock,
      margin: .only(right: 4.px),
      position: .relative(),
      cursor: .pointer,
      backgroundColor: ThemeColors.onSurfaceVariant,
      raw: {
        'mask-image':
            'url("data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' viewBox=\'0 0 24 24\'%3E%3Cpath d=\'M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z\'/%3E%3C/svg%3E")',
        'mask-repeat': 'no-repeat',
        'mask-position': 'center',
        'mask-size': 'contain',
      },
      transition: Transition('all', duration: 200.ms),
    ),
    css('.toggle.expanded').styles(
      transform: Transform.rotate(90.deg),
    ),
    css('.spacer').styles(width: 16.px),
    css('.tag-open, .tag-close').styles(color: ThemeColors.onSurfaceVariant),
    css('.name').styles(color: ThemeColors.primary, fontWeight: FontWeight.bold),
    css('.tree-item.client .name').styles(color: Color('#3b82f6')),
    css('.tree-item.server .name').styles(color: Color('#ff9f1b')),
    css('.depth-limit').styles(
      color: ThemeColors.onSurfaceVariant,
      cursor: .pointer,
      fontSize: 1.rem,
      fontWeight: FontWeight.bold,
      padding: .symmetric(vertical: ThemeSpacing.s1),
      transition: Transition('all', duration: 150.ms),
    ),
    css('.depth-limit:hover').styles(
      color: ThemeColors.primary,
      backgroundColor: ThemeColors.surfaceContainerHighest,
    ),
  ];
}
