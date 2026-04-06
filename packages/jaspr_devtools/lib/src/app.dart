import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/devtools.dart';

import 'components/detail_panel.dart';
import 'components/search_bar.dart';
import 'components/toolbar.dart';
import 'components/tree_view.dart';
import 'connection/devtools_client.dart';
import 'theme/devtools_theme.dart';

/// Root component of the Jaspr DevTools app.
class DevToolsApp extends StatefulComponent {
  const DevToolsApp();

  @override
  State<DevToolsApp> createState() => _DevToolsAppState();
}

class _DevToolsAppState extends State<DevToolsApp> {
  late final DevToolsClient _client;
  InspectorNode? _tree;
  int? _selectedNodeId;
  String _searchQuery = '';
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _client = DevToolsClient();
    _client.treeUpdates.listen((tree) {
      setState(() {
        _tree = tree;
      });
    });
    _client.connectionState.listen((connected) {
      setState(() {
        _connected = connected;
      });
    });
    _client.connect();
  }

  @override
  void dispose() {
    _client.dispose();
    super.dispose();
  }

  int get _componentCount {
    if (_tree == null) return 0;
    return _countNodes(_tree!);
  }

  int _countNodes(InspectorNode node) {
    var count = 1;
    for (final child in node.children) {
      count += _countNodes(child);
    }
    return count;
  }

  InspectorNode? get _selectedNode {
    if (_tree == null || _selectedNodeId == null) return null;
    return _findNode(_tree!, _selectedNodeId!);
  }

  InspectorNode? _findNode(InspectorNode node, int id) {
    if (node.id == id) return node;
    for (final child in node.children) {
      final found = _findNode(child, id);
      if (found != null) return found;
    }
    return null;
  }

  void _onSelect(int nodeId) {
    setState(() {
      _selectedNodeId = nodeId;
    });
    // Tell the running app to highlight this element.
    _client.highlightElement(nodeId);
  }

  @override
  Component build(BuildContext context) {
    return div(
      [
        // Toolbar
        DevToolsToolbar(
          onRefresh: _client.requestTree,
          connected: _connected,
          componentCount: _componentCount,
        ),
        // Search
        SearchBar(
          value: _searchQuery,
          onChanged: (q) => setState(() => _searchQuery = q),
        ),
        // Main content: tree + detail
        div(
          [
            // Tree panel (left)
            div(
              [
                TreeView(
                  tree: _tree,
                  selectedId: _selectedNodeId,
                  onSelect: _onSelect,
                  searchQuery: _searchQuery,
                ),
              ],
              styles: Styles(raw: {
                'flex': '1',
                'display': 'flex',
                'flex-direction': 'column',
                'overflow': 'hidden',
                'border-right': '1px solid ${DevToolsColors.border}',
              }),
            ),
            // Detail panel (right)
            div(
              [
                DetailPanel(node: _selectedNode),
              ],
              styles: Styles(raw: {
                'width': '320px',
                'flex-shrink': '0',
                'background': DevToolsColors.surface,
                'overflow-y': 'auto',
              }),
            ),
          ],
          styles: Styles(raw: {
            'display': 'flex',
            'flex': '1',
            'overflow': 'hidden',
          }),
        ),
      ],
      styles: Styles(raw: {
        'display': 'flex',
        'flex-direction': 'column',
        'height': '100vh',
        'width': '100vw',
        'background': DevToolsColors.background,
        'color': DevToolsColors.textPrimary,
        'font-family': '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, monospace',
      }),
    );
  }
}
