import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/split_view.dart';
import '../components/tree_view.dart';
import '../models/tree_state.dart';
import '../styles/theme.dart';

@Import.onWeb('main_app_state.dart', show: [#MainAppState])
@Import.onWeb('../services/component_tree_service.dart', show: [#ComponentTreeService])
import 'component_tree_page.imports.dart';

class ComponentTreePage extends StatefulComponent {
  const ComponentTreePage({super.key});

  @override
  State<ComponentTreePage> createState() => ComponentTreePageState();
}

class ComponentTreePageState extends State<ComponentTreePage> {
  late ComponentTreeServiceOrStubbed treeService;
  bool initialized = false;

  String? selectedUrl;
  TreeMode mode = TreeMode.combined;
  DiagnosticsNode? selectedNode;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (initialized) {
      treeService.removeListener(updateTree);
    }
    initialized = true;
    treeService = MainAppState.of(context).treeService;
    treeService.addListener(updateTree);
    updateTree();

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    treeService.removeListener(updateTree);
    super.dispose();
  }

  void updateTree() {
    // Simple logic to pick first URL if none selected
    final urls = treeService.allUrls;
    if (!urls.contains(selectedUrl)) {
      selectedUrl = urls.isNotEmpty ? urls.first : null;
    }

    setState(() {});
  }

  @override
  Component build(BuildContext context) {
    final root = selectedUrl != null ? treeService.getTree(selectedUrl!, mode: mode) : null;

    return div(classes: 'page-container', [
      div(classes: 'toolbar', [
        div(classes: 'tabs-container', [
          for (final url in treeService.allUrls)
            div(
              classes: 'tab ${url == selectedUrl ? 'active' : ''}',
              events: {
                'click': (e) => setState(() => selectedUrl = url),
              },
              [
                span([.text(url)]),
                div(
                  classes: 'tab-close',
                  events: {
                    'click': (e) {
                      e.stopPropagation();
                      treeService.removeTree(url);
                    },
                  },
                  [.text('×')],
                ),
              ],
            ),
        ]),
      ]),
      SplitView(
        first: div(classes: 'tree-container', [
          div(classes: 'tree-mode-overlay', [
            div(classes: 'button-group', [
              for (final m in TreeMode.values)
                button(
                  classes: 'toggle-btn ${mode == m ? 'active' : ''}',
                  onClick: () => setState(() => mode = m),
                  [.text(m.name[0].toUpperCase() + m.name.substring(1))],
                ),
            ]),
          ]),
          div(classes: 'tree-content', [
            TreeView(
              key: ValueKey(mode),
              root: root,
              selected: selectedNode,
              onSelected: (node) => setState(() => selectedNode = node),
            ),
          ]),
        ]),
        second: selectedNode == null
            ? .fragment([])
            : div(classes: 'properties-container', [
                div(classes: 'properties-header', [.text('PROPERTIES: ${selectedNode!.name.toUpperCase()}')]),
                div(classes: 'properties-content', [
                  if (selectedNode!.properties?.isEmpty ?? true)
                    div(classes: 'empty-msg', [.text('No properties available for this component.')])
                  else
                    table(classes: 'properties-table', [
                      tbody([
                        if (selectedNode!.properties != null)
                          for (final prop in selectedNode!.properties!)
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
              ]),
      ),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.page-container').styles(
      display: .flex,
      flexDirection: .column,
      height: .percent(100),
      overflow: .hidden,
    ),
    css('.toolbar').styles(
      height: 35.px,
      backgroundColor: ThemeColors.surfaceContainerLow,
      display: .flex,
      alignItems: .center,
      flex: .shrink(0),
      border: Border.only(
        bottom: BorderSide(width: 1.px, color: ThemeColors.surfaceContainerHighest),
      ),
    ),
    css('.tabs-container').styles(
      display: .flex,
      flex: Flex(grow: 1),
      height: 100.percent,
      overflow: .hidden,
      raw: {'overflow-x': 'auto', 'scrollbar-width': 'none'},
    ),
    css('.tab').styles(
      display: .flex,
      alignItems: .center,
      padding: .symmetric(horizontal: ThemeSpacing.s4),
      cursor: .pointer,
      fontSize: 0.75.rem,
      color: ThemeColors.onSurfaceVariant,
      backgroundColor: ThemeColors.surfaceContainerLow,
      border: Border.only(
        right: BorderSide(width: 1.px, color: ThemeColors.surfaceContainerHighest),
      ),
      transition: Transition('all', duration: 150.ms),
      whiteSpace: .noWrap,
      gap: .all(ThemeSpacing.s2),
    ),
    css('.tab:hover').styles(
      backgroundColor: ThemeColors.surfaceContainerHigh,
      color: ThemeColors.onSurface,
    ),
    css('.tab.active').styles(
      color: ThemeColors.primary,
      backgroundColor: ThemeColors.surface,
    ),
    css('.tab-close').styles(
      display: .flex,
      alignItems: .center,
      justifyContent: .center,
      width: 16.px,
      height: 16.px,
      radius: .circular(2.px),
      fontSize: 14.px,
      transition: Transition('all', duration: 150.ms),
    ),
    css('.tab-close:hover').styles(
      backgroundColor: ThemeColors.surfaceContainerHighest,
      color: ThemeColors.onSurface,
    ),
    css('.tree-container').styles(
      display: .flex,
      flexDirection: .column,
      height: .percent(100),
      position: .relative(),
      overflow: .hidden,
    ),
    css('.tree-content').styles(
      flex: Flex(grow: 1),
      overflow: .auto,
    ),
    css('.tree-mode-overlay').styles(
      position: .absolute(top: 12.px, right: 12.px),
      zIndex: ZIndex(10),
    ),
    css('.button-group').styles(
      display: .flex,
      backgroundColor: ThemeColors.surfaceContainerHigh,
      radius: .circular(4.px),
      overflow: .hidden,
      border: Border.all(width: 1.px, color: ThemeColors.outlineVariant),
      raw: {
        'box-shadow': '0 4px 12px rgba(0,0,0,0.5)',
        'backdrop-filter': 'blur(4px)',
      },
    ),
    css('.toggle-btn').styles(
      backgroundColor: Colors.transparent,
      color: ThemeColors.onSurfaceVariant,
      border: .none,
      padding: .symmetric(horizontal: 10.px, vertical: 4.px),
      cursor: .pointer,
      fontSize: 0.7.rem,
      fontWeight: FontWeight.w500,
      transition: Transition('all', duration: 150.ms),
    ),
    css('.toggle-btn:hover').styles(
      color: ThemeColors.onSurface,
      backgroundColor: ThemeColors.surfaceContainerHighest,
    ),
    css('.toggle-btn.active').styles(
      backgroundColor: ThemeColors.primary,
      color: ThemeColors.background,
      fontWeight: FontWeight.bold,
    ),
    css('.properties-container').styles(
      display: .flex,
      flexDirection: .column,
      height: .percent(100),
      backgroundColor: ThemeColors.surfaceContainerLowest,
    ),
    css('.properties-header').styles(
      padding: .all(ThemeSpacing.s2),
      fontSize: 0.65.rem,
      fontWeight: FontWeight.bold,
      color: ThemeColors.onSurfaceVariant,
      backgroundColor: ThemeColors.surfaceContainerLow,
      letterSpacing: 0.05.rem,
      border: Border.only(
        bottom: BorderSide(width: 1.px, color: ThemeColors.surfaceContainerHighest),
      ),
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
      padding: .symmetric(vertical: 4.px, horizontal: 8.px),
      color: ThemeColors.onSurfaceVariant,
      width: 35.percent,
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
