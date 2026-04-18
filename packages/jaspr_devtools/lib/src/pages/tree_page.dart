import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/button_group.dart';
import '../components/dropdown.dart';
import '../components/split_view.dart';
import '../components/tree_view.dart';
import '../models/tree_state.dart';
import '../services/tree_service.dart';
import '../styles/theme.dart';

class TreePage extends StatefulComponent {
  const TreePage({super.key});

  @override
  State<TreePage> createState() => TreePageState();
}

class TreePageState extends State<TreePage> {
  bool initialized = false;

  String? selectedUrl;

  @override
  void initState() {
    super.initState();
    TreeService.instance.addListener(updateTree);
  }

  @override
  void dispose() {
    TreeService.instance.removeListener(updateTree);
    super.dispose();
  }

  void updateTree() {
    // Simple logic to pick first URL if none selected
    final urls = TreeService.instance.allUrls;
    if (!urls.contains(selectedUrl)) {
      selectedUrl = urls.isNotEmpty ? urls.first : null;
    }

    setState(() {});
  }

  @override
  Component build(BuildContext context) {
    final treeState = selectedUrl != null ? TreeService.instance.getTree(selectedUrl!) : null;
    String urlLabel(String url) {
      final tree = TreeService.instance.getTree(url);
      if (tree?.clientTree?.title case final title?) {
        return '$url | $title';
      }
      return url;
    }

    return div(classes: 'page-container', [
      SplitView(
        first: div(classes: 'tree-container', [
          div(classes: 'tree-url-overlay', [
            Dropdown<String>(
              value: selectedUrl,
              options: TreeService.instance.allUrls,
              onChange: (value) {
                setState(() => selectedUrl = value);
              },
              getLabel: urlLabel,
              getTitle: (url) => url != null ? 'Page: ${urlLabel(url)}' : 'Select page...',
            ),
          ]),
          if (treeState != null)
            div(classes: 'tree-mode-overlay', [
              ValueListenableBuilder(
                listenable: treeState.activeMode,
                builder: (context, mode) {
                  return ButtonGroup<TreeMode>(
                    items: TreeMode.values,
                    value: mode,
                    onChanged: (value) {
                      treeState.setMode(value);
                    },
                    getLabel: (m) => m.name[0].toUpperCase() + m.name.substring(1),
                  );
                },
              ),
            ]),
          if (treeState != null)
            div(classes: 'tree-content', [
              ValueListenableBuilder(
                listenable: treeState.activeRoot,
                builder: (context, root) {
                  return TreeView(
                    key: ValueKey(treeState.activeMode),
                    root: root,
                  );
                },
              ),
            ]),
        ]),
        second: treeState != null
            ? ValueListenableBuilder(
                listenable: treeState.activeRoot,
                builder: (context, root) {
                  return ValueListenableBuilder(
                    listenable: TreeService.instance.selectedElementId,
                    builder: (context, selectedElementId) {
                      final selectedNode = root?.findNodeById(selectedElementId);
                      if (selectedNode == null) {
                        return .empty();
                      }
                      return div(classes: 'properties-container', [
                        // div(classes: 'properties-header', [
                        //   .text(
                        //     'PROPERTIES: ${selectedNode.properties?.get('type')?.toString() ?? selectedNode.name.toUpperCase()}',
                        //   ),
                        // ]),
                        div(classes: 'properties-content', [
                          if (selectedNode.properties?.isEmpty ?? true)
                            div(classes: 'empty-msg', [.text('No properties available for this component.')])
                          else
                            table(classes: 'properties-table', [
                              tbody([
                                if (selectedNode.properties != null)
                                  for (final prop in selectedNode.properties!)
                                    if (prop.name == 'component')
                                      for (final prop2 in prop.properties ?? <DiagnosticsProperty>[])
                                        tr([
                                          td(classes: 'prop-name', [.text(prop2.name)]),
                                          td(classes: 'prop-value', [
                                            .text(
                                              prop2.value.toString(),
                                            ),
                                          ]),
                                        ])
                                    else
                                      tr([
                                        td(classes: 'prop-name', [.text(prop.name)]),
                                        td(classes: 'prop-value', [
                                          .text(
                                            prop.value.toString(),
                                          ),
                                        ]),
                                      ]),
                              ]),
                            ]),
                        ]),
                      ]);
                    },
                  );
                },
              )
            : .empty(),
      ),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.page-container').styles(
      display: .flex,
      height: .percent(100),
      overflow: .hidden,
      flexDirection: .column,
    ),
    css('.tree-container').styles(
      display: .flex,
      position: .relative(),
      height: .percent(100),
      padding: Padding.only(top: 2.5.rem),
      overflow: .hidden,
      flexDirection: .column,
    ),
    css('.tree-content').styles(
      overflow: .auto,
      flex: Flex(grow: 1),
    ),
    css('.tree-url-overlay').styles(
      position: .absolute(top: 12.px, left: 12.px),
      zIndex: ZIndex(10),
    ),
    css('.tree-mode-overlay').styles(
      position: .absolute(top: 12.px, right: 12.px),
      zIndex: ZIndex(10),
    ),

    css('.properties-container').styles(
      display: .flex,
      height: .percent(100),
      flexDirection: .column,
      backgroundColor: ThemeColors.surfaceContainerLowest,
    ),
    css('.properties-header').styles(
      padding: .all(ThemeSpacing.s2),
      border: Border.only(
        bottom: BorderSide(width: 1.px, color: ThemeColors.surfaceContainerHighest),
      ),
      color: ThemeColors.onSurfaceVariant,
      fontSize: 0.65.rem,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.05.rem,
      backgroundColor: ThemeColors.surfaceContainerLow,
    ),
    css('.empty-msg').styles(
      padding: .all(ThemeSpacing.s8),
      color: ThemeColors.onSurfaceVariant,
      textAlign: .center,
      fontSize: 0.8.rem,
    ),
    css('.properties-table').styles(
      width: 100.percent,
      raw: {'border-collapse': 'collapse'},
    ),
    css('.properties-table tr').styles(
      border: Border.only(
        bottom: BorderSide(width: 1.px, color: ThemeColors.surfaceContainerLow),
      ),
    ),
    css('.prop-name').styles(
      width: 35.percent,
      padding: .symmetric(vertical: 4.px, horizontal: 8.px),
      color: ThemeColors.onSurfaceVariant,
      fontSize: 0.8.rem,
      raw: {'vertical-align': 'top'},
    ),
    css('.prop-value').styles(
      padding: .symmetric(vertical: 4.px, horizontal: 8.px),
      color: ThemeColors.primary,
      fontFamily: .list([FontFamily('JetBrains Mono'), FontFamilies.monospace]),
      fontSize: 0.8.rem,
      raw: {'word-break': 'break-all'},
    ),
  ];
}
