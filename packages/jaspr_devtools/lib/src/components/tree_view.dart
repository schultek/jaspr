import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import '../models/tree_state.dart';
import '../services/tree_service.dart';
import '../styles/theme.dart';

class TreeView extends StatefulComponent {
  const TreeView({
    required this.root,
    super.key,
  });

  final ActiveTreeItem? root;

  @override
  State createState() => TreeViewState();
}

class TreeViewState extends State<TreeView> {
  @override
  void initState() {
    super.initState();
    TreeService.instance.selectedElementId.addListener(scrollToSelectedElement);
  }

  @override
  void didUpdateComponent(covariant TreeView oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.root != component.root) {
      scrollToSelectedElement();
    }
  }

  @override
  void dispose() {
    TreeService.instance.selectedElementId.removeListener(scrollToSelectedElement);
    super.dispose();
  }

  void scrollToSelectedElement() {
    final id = TreeService.instance.selectedElementId.value;
    if (id == null) return;
    context.binding.addPostFrameCallback(() {
      web.document
          .querySelector('.tree-item[data-id="$id"] .name')
          ?.scrollIntoView(web.ScrollIntoViewOptions(behavior: 'smooth', block: 'center', inline: 'center'));
    });
  }

  @override
  Component build(BuildContext context) {
    if (component.root == null) {
      return div(classes: 'tree-empty', [.text('No component tree available.')]);
    }

    return div(classes: 'tree-view', [
      TreeItem(
        item: component.root!,
        depth: 1,
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
      color: ThemeColors.onSurfaceVariant,
      textAlign: .center,
      fontStyle: FontStyle.italic,
    ),
  ];
}

class TreeItem extends StatelessComponent {
  const TreeItem({
    required this.item,
    required this.depth,
    super.key,
  });

  final ActiveTreeItem item;
  final int depth;

  static const inset = 16;

  @override
  Component build(BuildContext context) {
    final hasChildren = item.node.children?.isNotEmpty ?? false;

    final type = item.node.properties?.get('type')?.value.toString();

    final name = switch (type) {
      'DomComponent' =>
        item.node.properties?.get('component')?.properties?.get('tag')?.value.toString() ?? 'DomComponent',
      _ => type ?? item.node.name,
    };

    final envClass = item.isClient ? 'client' : 'server';

    return ValueListenableBuilder(
      listenable: item.expanded,
      builder: (context, expanded) {
        return div(classes: 'tree-item-container', [
          span(
            classes: 'line',
            styles: Styles(position: .absolute(left: ((depth - 1) * inset + 6).px)),
            [],
          ),
          ValueListenableBuilder(
            listenable: TreeService.instance.selectedElementId,
            builder: (context, selectedElementId) {
              final isSelected = selectedElementId == item.id;
              return div(
                classes: 'tree-item ${isSelected ? 'selected' : ''} $envClass',
                attributes: {'data-id': item.id ?? ''},
                events: {
                  'click': (e) {
                    e.stopPropagation();
                    if (item.id case final id?) {
                      TreeService.instance.selectElement(id);
                    }
                  },
                },
                styles: Styles(padding: .only(left: (depth * inset).px)),
                [
                  span(classes: 'hline ${hasChildren ? '' : 'wide'}', []),
                  if (hasChildren)
                    span(
                      classes: 'toggle ${expanded ? 'expanded' : ''}',
                      events: {
                        'click': (e) {
                          e.stopPropagation();
                          item.toggleExpanded();
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
              );
            },
          ),
          if (hasChildren && expanded)
            for (final child in item.children)
              TreeItem(
                item: child,
                depth: depth + 1,
              ),
        ]);
      },
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.tree-item').styles(
      display: .flex,
      padding: .symmetric(vertical: 2.px, horizontal: 2.rem),
      cursor: .pointer,
      transition: Transition('all', duration: 100.ms),
      alignItems: .center,
      whiteSpace: .noWrap,
    ),
    css('.tree-item:hover').styles(
      backgroundColor: ThemeColors.surfaceContainerHighest,
    ),
    css('.tree-item.selected').styles(
      border: Border.only(
        left: BorderSide(width: 2.px, color: ThemeColors.primary),
      ),
      backgroundColor: ThemeColors.surfaceContainerHigh,
    ),
    css('.toggle').styles(
      display: .inlineBlock,
      position: .relative(),
      width: 12.px,
      height: 12.px,
      margin: .only(right: 4.px),
      cursor: .pointer,
      transition: Transition('all', duration: 200.ms),
      backgroundColor: ThemeColors.onSurfaceVariant,
      raw: {
        'mask-image':
            'url("data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' viewBox=\'0 0 24 24\'%3E%3Cpath d=\'M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z\'/%3E%3C/svg%3E")',
        'mask-repeat': 'no-repeat',
        'mask-position': 'center',
        'mask-size': 'contain',
      },
    ),
    css('.toggle.expanded').styles(
      transform: Transform.rotate(90.deg),
    ),
    css('.spacer').styles(width: 16.px),
    css('.tag-open, .tag-close').styles(color: ThemeColors.outlineVariant),
    css('.name').styles(fontWeight: FontWeight.normal),
    css('.tree-item.client').styles(color: Color('#8bb2f4')),
    css('.tree-item.server').styles(color: Color('#ffba5a')),
    css('.tree-item-container').styles(
      position: Position.relative(),
    ),
    css('.tree-item-container > .tree-item-container > .line').styles(
      display: .block,
      position: Position.absolute(top: (-3).px, bottom: 0.px),
      zIndex: ZIndex(2),
      width: 1.px,
      backgroundColor: ThemeColors.outlineVariant,
    ),
    css('.tree-item-container > .tree-item-container:last-child > .line').styles(
      position: Position.absolute(bottom: Unit.unset),
      height: Unit.expression('calc(1em + 3px)'),
    ),
    css('.tree-item-container > .tree-item').styles(position: Position.relative()),
    css('.tree-item-container > .tree-item-container > .tree-item > .hline').styles(
      display: .block,
      position: Position.absolute(),
      width: 8.px,
      height: 1.px,
      transform: Transform.translate(x: (-10).px),
      backgroundColor: ThemeColors.outlineVariant,
    ),
    css('.tree-item-container > .tree-item-container > .tree-item > .hline.wide').styles(
      width: 20.px,
    ),
  ];
}
