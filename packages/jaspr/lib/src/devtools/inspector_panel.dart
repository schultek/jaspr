import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:universal_web/web.dart' as web;

import '../dom/type_checks.dart';
import 'tree_snapshot.dart';

/// Callback invoked when a tree node is selected in the inspector panel.
///
/// Receives the [nodeId] (element hashCode) of the selected node.
typedef NodeSelectionCallback = void Function(int nodeId);

/// Callback invoked when the user requests a tree refresh.
typedef VoidActionCallback = void Function();

/// Callback invoked when pick mode is toggled.
typedef PickModeCallback = void Function(bool active);

/// Default depth up to which tree nodes are auto-expanded.
const _kAutoExpandDepth = 2;

/// Badge background colors keyed by component kind.
const _kTagColors = {
  'dom': '#2d7d46',
  'text': '#7d6d2d',
  'stateful': '#2d4a7d',
  'component': '#555',
};

/// IDE options for "Open in IDE" settings.
const _kIdeOptions = {
  'vscode': 'VS Code',
  'cursor': 'Cursor',
  'idea': 'IntelliJ IDEA',
  'webstorm': 'WebStorm',
};

/// Renders the inspector panel as a pure DOM overlay.
///
/// The panel displays a collapsible component tree and an info bar showing
/// details about the currently selected node. It uses event delegation on the
/// tree container to avoid per-node listener accumulation.
class InspectorPanel {
  /// Creates an [InspectorPanel] and immediately builds its DOM structure.
  ///
  /// [onNodeSelected] is called whenever a tree node label is clicked.
  /// [onRefresh] is called when the refresh button is pressed.
  /// [onPickModeChanged] is called when pick mode is toggled.
  /// [onVisibilityChanged] is called when the panel becomes visible.
  InspectorPanel({
    required this.onNodeSelected,
    required this.onRefresh,
    required this.onPickModeChanged,
    this.onVisibilityChanged,
    this.onInspectInDevTools,
  }) {
    _injectStyles();
    _buildDom();
    _fetchProjectInfo();
  }

  /// Called when a node label is clicked, with the node's id.
  final NodeSelectionCallback onNodeSelected;

  /// Called when the refresh button is clicked.
  final VoidActionCallback onRefresh;

  /// Called when pick mode is toggled.
  final PickModeCallback onPickModeChanged;

  /// Called when the panel becomes visible (for restarting post-frame refresh).
  final VoidActionCallback? onVisibilityChanged;

  /// Called when the user clicks "Inspect DOM" to reveal a node in browser DevTools.
  final NodeSelectionCallback? onInspectInDevTools;

  late final web.HTMLDivElement _root;
  late final web.HTMLDivElement _panel;
  late final web.HTMLDivElement _treeContainer;
  late final web.HTMLDivElement _detailPanel;
  late final web.HTMLButtonElement _toggleButton;
  late final web.HTMLButtonElement _pickBtn;
  late final web.HTMLInputElement _searchInput;
  bool _visible = false;
  bool _pickMode = false;
  /// Package name → absolute lib path, fetched from the dev server.
  Map<String, String> _packagePaths = {};
  int? _selectedNodeId;

  /// Tracks which node IDs are expanded. Persists across tree re-renders.
  final Set<int> _expandedNodeIds = {};
  bool _treeInitialized = false;

  /// The most recently rendered tree (for looking up selected node info).
  InspectorNode? _currentTree;

  /// The root DOM element that should be appended to the document body.
  web.HTMLDivElement get rootElement => _root;

  void _injectStyles() {
    const styleId = 'jaspr-devtools-styles';
    if (web.document.getElementById(styleId) != null) return;
    final style = web.document.createElement('style') as web.HTMLStyleElement;
    style.id = styleId;
    style.textContent = _cssText;
    web.document.head!.append(style);
  }

  void _buildDom() {
    _root = web.document.createElement('div') as web.HTMLDivElement;
    _root.id = 'jaspr-devtools-root';

    // Toggle button
    _toggleButton = web.document.createElement('button') as web.HTMLButtonElement;
    _toggleButton.id = 'jaspr-devtools-toggle';
    _toggleButton.textContent = '\u2699'; // gear icon
    _toggleButton.addEventListener(
      'click',
      ((web.Event e) {
        toggle();
      }).toJS,
    );
    _root.append(_toggleButton);

    // Panel
    _panel = web.document.createElement('div') as web.HTMLDivElement;
    _panel.id = 'jaspr-devtools-panel';
    _panel.style.display = 'none';

    // Restore persisted width
    final savedWidth = web.window.localStorage.getItem('jaspr-dt-width');
    if (savedWidth != null) _panel.style.width = '${savedWidth}px';

    // Resize handle on left edge
    final resizeHandle = web.document.createElement('div') as web.HTMLDivElement;
    resizeHandle.className = 'jaspr-dt-resize';
    _setupResizeHandle(resizeHandle);
    _panel.append(resizeHandle);

    // Header
    final header = web.document.createElement('div') as web.HTMLDivElement;
    header.className = 'jaspr-dt-header';
    final headerTitle = web.document.createElement('span') as web.HTMLSpanElement;
    headerTitle.textContent = 'Jaspr Inspector';
    header.append(headerTitle);

    final headerActions = web.document.createElement('span') as web.HTMLSpanElement;

    // Pick mode button
    _pickBtn = web.document.createElement('button') as web.HTMLButtonElement;
    _pickBtn.className = 'jaspr-dt-btn';
    _pickBtn.textContent = '\u2295'; // ⊕ crosshair-like symbol
    _pickBtn.title = 'Pick element';
    _pickBtn.addEventListener(
      'click',
      ((web.Event e) {
        setPickMode(!_pickMode);
      }).toJS,
    );
    headerActions.append(_pickBtn);

    final refreshBtn = web.document.createElement('button') as web.HTMLButtonElement;
    refreshBtn.className = 'jaspr-dt-btn';
    refreshBtn.textContent = '\u21BB'; // refresh symbol
    refreshBtn.title = 'Refresh tree';
    refreshBtn.addEventListener(
      'click',
      ((web.Event e) {
        onRefresh();
      }).toJS,
    );
    headerActions.append(refreshBtn);

    final settingsBtn = web.document.createElement('button') as web.HTMLButtonElement;
    settingsBtn.className = 'jaspr-dt-btn';
    settingsBtn.textContent = '\u2699'; // ⚙ gear icon
    settingsBtn.title = 'Settings';
    settingsBtn.addEventListener(
      'click',
      ((web.Event e) {
        _showSettingsDialog();
      }).toJS,
    );
    headerActions.append(settingsBtn);

    final closeBtn = web.document.createElement('button') as web.HTMLButtonElement;
    closeBtn.className = 'jaspr-dt-btn';
    closeBtn.textContent = '\u00D7'; // × symbol
    closeBtn.title = 'Close';
    closeBtn.addEventListener(
      'click',
      ((web.Event e) {
        toggle();
      }).toJS,
    );
    headerActions.append(closeBtn);
    header.append(headerActions);
    _panel.append(header);

    // Search bar
    final searchBar = web.document.createElement('div') as web.HTMLDivElement;
    searchBar.className = 'jaspr-dt-search';
    _searchInput = web.document.createElement('input') as web.HTMLInputElement;
    _searchInput.className = 'jaspr-dt-search-input';
    _searchInput.placeholder = 'Search components...';
    _searchInput.type = 'text';
    _searchInput.addEventListener(
      'input',
      ((web.Event e) {
        _filterTree(_searchInput.value);
      }).toJS,
    );
    searchBar.append(_searchInput);
    _panel.append(searchBar);

    // Tree container with delegated click handler
    _treeContainer = web.document.createElement('div') as web.HTMLDivElement;
    _treeContainer.className = 'jaspr-dt-tree';
    _treeContainer.tabIndex = 0;
    _treeContainer.addEventListener(
      'click',
      ((web.Event e) {
        final target = e.target;
        if (target == null || !target.isElement) return;
        final el = target as web.Element;

        if (el.classList.contains('jaspr-dt-arrow')) {
          _handleArrowClick(el);
        } else if (el.classList.contains('jaspr-dt-label')) {
          _handleLabelClick(el);
        }
      }).toJS,
    );
    _setupKeyboardNav();
    _panel.append(_treeContainer);

    // Drag divider between tree and detail panel
    final divider = web.document.createElement('div') as web.HTMLDivElement;
    divider.className = 'jaspr-dt-divider';
    _setupVerticalDivider(divider);
    _panel.append(divider);

    // Detail panel
    _detailPanel = web.document.createElement('div') as web.HTMLDivElement;
    _detailPanel.className = 'jaspr-dt-detail';

    // Restore persisted detail height
    final savedHeight = web.window.localStorage.getItem('jaspr-dt-detail-height');
    if (savedHeight != null) {
      _detailPanel.style.minHeight = '${savedHeight}px';
      _detailPanel.style.maxHeight = '${savedHeight}px';
    }

    _panel.append(_detailPanel);

    _root.append(_panel);
  }

  void _setupResizeHandle(web.HTMLDivElement handle) {
    handle.addEventListener(
      'mousedown',
      ((web.MouseEvent e) {
        e.preventDefault();
        final startX = e.clientX;
        final startWidth = _panel.offsetWidth;

        JSFunction? onMove;
        JSFunction? onUp;

        onMove = ((web.MouseEvent moveEvent) {
          final delta = startX - moveEvent.clientX;
          final newWidth = (startWidth + delta).clamp(200, web.window.innerWidth * 0.8).toInt();
          _panel.style.width = '${newWidth}px';
        }).toJS;

        onUp = ((web.MouseEvent upEvent) {
          web.document.removeEventListener('mousemove', onMove!);
          web.document.removeEventListener('mouseup', onUp!);
          web.window.localStorage.setItem('jaspr-dt-width', '${_panel.offsetWidth}');
        }).toJS;

        web.document.addEventListener('mousemove', onMove);
        web.document.addEventListener('mouseup', onUp);
      }).toJS,
    );
  }

  void _setupVerticalDivider(web.HTMLDivElement divider) {
    divider.addEventListener(
      'mousedown',
      ((web.MouseEvent e) {
        e.preventDefault();
        final startY = e.clientY;
        final startHeight = _detailPanel.offsetHeight;

        JSFunction? onMove;
        JSFunction? onUp;

        onMove = ((web.MouseEvent moveEvent) {
          final delta = startY - moveEvent.clientY;
          final panelHeight = _panel.offsetHeight;
          final newHeight = (startHeight + delta).clamp(60, (panelHeight * 0.7).toInt()).toInt();
          _detailPanel.style.minHeight = '${newHeight}px';
          _detailPanel.style.maxHeight = '${newHeight}px';
        }).toJS;

        onUp = ((web.MouseEvent upEvent) {
          web.document.removeEventListener('mousemove', onMove!);
          web.document.removeEventListener('mouseup', onUp!);
          web.window.localStorage.setItem('jaspr-dt-detail-height', '${_detailPanel.offsetHeight}');
        }).toJS;

        web.document.addEventListener('mousemove', onMove);
        web.document.addEventListener('mouseup', onUp);
      }).toJS,
    );
  }

  void _setupKeyboardNav() {
    _treeContainer.addEventListener(
      'keydown',
      ((web.KeyboardEvent e) {
        final nodes = _treeContainer.querySelectorAll('.jaspr-dt-node:not(.search-hidden)');
        if (nodes.length == 0) return;

        int currentIndex = -1;
        for (var i = 0; i < nodes.length; i++) {
          if ((nodes.item(i)! as web.Element).classList.contains('selected')) {
            currentIndex = i;
            break;
          }
        }

        switch (e.key) {
          case 'ArrowDown':
            e.preventDefault();
            final nextIndex = (currentIndex + 1).clamp(0, nodes.length - 1);
            _selectNodeAtIndex(nodes, nextIndex);
          case 'ArrowUp':
            e.preventDefault();
            final prevIndex = (currentIndex - 1).clamp(0, nodes.length - 1);
            _selectNodeAtIndex(nodes, prevIndex);
          case 'ArrowRight':
            e.preventDefault();
            if (currentIndex >= 0) {
              final row = nodes.item(currentIndex)! as web.HTMLElement;
              final arrow = row.querySelector('.jaspr-dt-arrow') as web.HTMLElement?;
              if (arrow != null && arrow.dataset['expanded'] == 'false') {
                _handleArrowClick(arrow);
              }
            }
          case 'ArrowLeft':
            e.preventDefault();
            if (currentIndex >= 0) {
              final row = nodes.item(currentIndex)! as web.HTMLElement;
              final arrow = row.querySelector('.jaspr-dt-arrow') as web.HTMLElement?;
              if (arrow != null && arrow.dataset['expanded'] == 'true') {
                _handleArrowClick(arrow);
              } else {
                // Move to parent node
                var parent = row.parentElement;
                while (parent != null && parent != _treeContainer) {
                  if (parent.classList.contains('jaspr-dt-children')) {
                    final parentRow = parent.previousElementSibling;
                    if (parentRow != null && parentRow.classList.contains('jaspr-dt-node')) {
                      final idStr = parentRow.getAttribute('data-id');
                      if (idStr != null) {
                        final nodeId = int.tryParse(idStr);
                        if (nodeId != null) {
                          _clearSelection();
                          parentRow.classList.add('selected');
                          _selectedNodeId = nodeId;
                          _updateDetailPanel(nodeId);
                          (parentRow as web.HTMLElement).scrollIntoView();
                        }
                      }
                    }
                    break;
                  }
                  parent = parent.parentElement;
                }
              }
            }
          case 'Enter':
            e.preventDefault();
            if (currentIndex >= 0) {
              final row = nodes.item(currentIndex)! as web.Element;
              final idStr = row.getAttribute('data-id');
              if (idStr != null) {
                final nodeId = int.tryParse(idStr);
                if (nodeId != null) {
                  onNodeSelected(nodeId);
                }
              }
            }
        }
      }).toJS,
    );
  }

  void _selectNodeAtIndex(web.NodeList nodes, int index) {
    final row = nodes.item(index)! as web.Element;
    final idStr = row.getAttribute('data-id');
    if (idStr == null) return;
    final nodeId = int.tryParse(idStr);
    if (nodeId == null) return;

    _clearSelection();
    row.classList.add('selected');
    _selectedNodeId = nodeId;
    _updateDetailPanel(nodeId);
    (row as web.HTMLElement).scrollIntoView();
  }

  void _filterTree(String query) {
    final nodes = _treeContainer.querySelectorAll('.jaspr-dt-node');
    if (query.isEmpty) {
      for (var i = 0; i < nodes.length; i++) {
        final node = nodes.item(i)! as web.Element;
        node.classList.remove('search-hidden');
        node.classList.remove('search-match');
      }
      // Restore children container visibility
      final childContainers = _treeContainer.querySelectorAll('.jaspr-dt-children');
      for (var i = 0; i < childContainers.length; i++) {
        final container = childContainers.item(i)! as web.HTMLElement;
        final prevRow = container.previousElementSibling;
        if (prevRow != null) {
          final arrow = prevRow.querySelector('.jaspr-dt-arrow') as web.HTMLElement?;
          if (arrow != null) {
            container.style.display = arrow.dataset['expanded'] == 'true' ? 'block' : 'none';
          }
        }
      }
      return;
    }

    final lowerQuery = query.toLowerCase();
    final matchedNodes = <web.Element>{};

    // First pass: find matching nodes
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes.item(i)! as web.Element;
      final label = node.getAttribute('data-label') ?? '';
      if (label.toLowerCase().contains(lowerQuery)) {
        matchedNodes.add(node);
        node.classList.add('search-match');
        node.classList.remove('search-hidden');
        // Expand all ancestor containers
        var parent = node.parentElement;
        while (parent != null && parent != _treeContainer) {
          if (parent.classList.contains('jaspr-dt-children')) {
            (parent as web.HTMLElement).style.display = 'block';
            // Show parent row
            final prevRow = parent.previousElementSibling;
            if (prevRow != null && prevRow.classList.contains('jaspr-dt-node')) {
              matchedNodes.add(prevRow);
            }
          }
          parent = parent.parentElement;
        }
      } else {
        node.classList.remove('search-match');
      }
    }

    // Second pass: hide non-matching nodes
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes.item(i)! as web.Element;
      if (!matchedNodes.contains(node)) {
        node.classList.add('search-hidden');
      } else {
        node.classList.remove('search-hidden');
      }
    }
  }

  /// Toggles pick mode on or off externally.
  void setPickMode(bool active) {
    _pickMode = active;
    if (active) {
      _pickBtn.classList.add('jaspr-dt-pick-active');
    } else {
      _pickBtn.classList.remove('jaspr-dt-pick-active');
    }
    onPickModeChanged(active);
  }

  /// Handles a delegated click on an arrow element to toggle expand/collapse.
  void _handleArrowClick(web.Element arrow) {
    final expanded = (arrow as web.HTMLElement).dataset['expanded'] == 'true';
    arrow.dataset['expanded'] = expanded ? 'false' : 'true';
    arrow.textContent = expanded ? '\u25B6' : '\u25BC';

    // Track expand state by node ID.
    final row = arrow.parentElement;
    if (row == null) return;
    final idStr = row.getAttribute('data-id');
    if (idStr != null) {
      final nodeId = int.tryParse(idStr);
      if (nodeId != null) {
        if (expanded) {
          _expandedNodeIds.remove(nodeId);
        } else {
          _expandedNodeIds.add(nodeId);
        }
      }
    }

    // The children container is the next sibling of the arrow's parent row.
    final childContainer = row.nextElementSibling;
    if (childContainer == null) return;
    if (childContainer.classList.contains('jaspr-dt-children')) {
      (childContainer as web.HTMLElement).style.display = expanded ? 'none' : 'block';
    }
  }

  /// Handles a delegated click on a label element to select a node.
  void _handleLabelClick(web.Element label) {
    final row = label.parentElement;
    if (row == null) return;
    final idStr = row.getAttribute('data-id');
    if (idStr == null) return;
    final nodeId = int.tryParse(idStr);
    if (nodeId == null) return;

    _selectedNodeId = nodeId;
    onNodeSelected(nodeId);

    _clearSelection();
    row.classList.add('selected');

    _updateDetailPanel(nodeId);
  }

  /// Shows or hides the panel.
  void toggle() {
    _visible = !_visible;
    _panel.style.display = _visible ? 'flex' : 'none';
    if (_visible) {
      onRefresh();
      onVisibilityChanged?.call();
    } else {
      // Exit pick mode when closing panel.
      if (_pickMode) setPickMode(false);
    }
  }

  /// Whether the panel is currently visible.
  bool get isVisible => _visible;

  /// Renders the given [tree] into the panel, replacing any previous content.
  ///
  /// Clears the tree container by removing child nodes (avoiding `innerHTML`)
  /// and recursively builds DOM elements for each [InspectorNode].
  void renderTree(InspectorNode tree) {
    _currentTree = tree;

    // On first render, auto-expand to default depth.
    if (!_treeInitialized) {
      _treeInitialized = true;
      _autoExpand(tree, 0);
    }

    // Remove children without innerHTML to properly release DOM nodes.
    while (_treeContainer.firstChild != null) {
      _treeContainer.removeChild(_treeContainer.firstChild!);
    }
    _renderNode(tree, _treeContainer, 0);

    // Re-select and update detail if a node was previously selected.
    if (_selectedNodeId != null) {
      final row = _treeContainer.querySelector('[data-id="$_selectedNodeId"]');
      if (row != null) {
        row.classList.add('selected');
      }
      _updateDetailPanel(_selectedNodeId!);
    }

    // Re-apply search filter if active
    if (_searchInput.value.isNotEmpty) {
      _filterTree(_searchInput.value);
    }
  }

  /// Populates [_expandedNodeIds] for the initial auto-expand to [_kAutoExpandDepth].
  void _autoExpand(InspectorNode node, int depth) {
    if (depth < _kAutoExpandDepth && node.children.isNotEmpty) {
      _expandedNodeIds.add(node.id);
      for (final child in node.children) {
        _autoExpand(child, depth + 1);
      }
    }
  }

  void _renderNode(InspectorNode node, web.HTMLElement parent, int currentDepth) {
    final row = web.document.createElement('div') as web.HTMLDivElement;
    row.className = 'jaspr-dt-node${node.id == _selectedNodeId ? ' selected' : ''}';
    row.dataset['id'] = '${node.id}';
    row.dataset['label'] = node.displayLabel;

    final hasChildren = node.children.isNotEmpty;

    // Arrow for expand/collapse
    final arrow = web.document.createElement('span') as web.HTMLSpanElement;
    arrow.className = 'jaspr-dt-arrow';
    if (hasChildren) {
      final expanded = _expandedNodeIds.contains(node.id);
      arrow.textContent = expanded ? '\u25BC' : '\u25B6'; // ▼ or ▶
      arrow.dataset['expanded'] = expanded ? 'true' : 'false';
    } else {
      arrow.textContent = ' ';
    }
    row.append(arrow);

    // Type tag badge
    final tag = web.document.createElement('span') as web.HTMLSpanElement;
    tag.className = 'jaspr-dt-tag';
    if (node.domTag != null) {
      tag.textContent = 'D';
      tag.title = 'DomComponent';
      tag.style.background = _kTagColors['dom']!;
    } else if (node.textContent != null) {
      tag.textContent = 'T';
      tag.title = 'Text';
      tag.style.background = _kTagColors['text']!;
    } else if (node.isStateful) {
      tag.textContent = 'S';
      tag.title = 'Stateful';
      tag.style.background = _kTagColors['stateful']!;
    } else {
      tag.textContent = 'C';
      tag.title = 'Component';
      tag.style.background = _kTagColors['component']!;
    }
    row.append(tag);

    // Label — no per-node listener; handled by delegation on _treeContainer.
    final label = web.document.createElement('span') as web.HTMLSpanElement;
    label.className = 'jaspr-dt-label';
    label.textContent = node.displayLabel;
    row.append(label);

    if (node.wasHydrated != null) {
      final origin = web.document.createElement('span') as web.HTMLSpanElement;
      origin.className = 'jaspr-dt-origin';
      origin.textContent = node.wasHydrated! ? 'SSR' : 'CSR';
      origin.style.background = node.wasHydrated! ? '#2d6b4f' : '#7d4a2d';
      row.append(origin);
    }

    parent.append(row);

    if (hasChildren) {
      final childContainer = web.document.createElement('div') as web.HTMLDivElement;
      childContainer.className = 'jaspr-dt-children';
      childContainer.style.display = _expandedNodeIds.contains(node.id) ? 'block' : 'none';

      for (final child in node.children) {
        _renderNode(child, childContainer, currentDepth + 1);
      }
      parent.append(childContainer);
    }
  }

  /// Selects a node by ID, expands all ancestors, and scrolls it into view.
  void selectAndReveal(int nodeId) {
    final row = _treeContainer.querySelector('[data-id="$nodeId"]');
    if (row == null) return;

    // Expand all ancestor .jaspr-dt-children containers.
    var parent = row.parentElement;
    while (parent != null && parent != _treeContainer) {
      if (parent.classList.contains('jaspr-dt-children')) {
        (parent as web.HTMLElement).style.display = 'block';
        // Update the arrow of the preceding row and track state.
        final prevRow = parent.previousElementSibling;
        if (prevRow != null) {
          final arrow = prevRow.querySelector('.jaspr-dt-arrow');
          if (arrow != null) {
            (arrow as web.HTMLElement).dataset['expanded'] = 'true';
            arrow.textContent = '\u25BC';
          }
          final parentIdStr = prevRow.getAttribute('data-id');
          if (parentIdStr != null) {
            final parentId = int.tryParse(parentIdStr);
            if (parentId != null) _expandedNodeIds.add(parentId);
          }
        }
      }
      parent = parent.parentElement;
    }

    // Scroll into view and select.
    (row as web.HTMLElement).scrollIntoView();
    _clearSelection();
    row.classList.add('selected');
    _selectedNodeId = nodeId;

    _updateDetailPanel(nodeId);
  }

  /// Updates the detail panel to show information about the node with [nodeId].
  void _updateDetailPanel(int nodeId) {
    // Clear existing content.
    while (_detailPanel.firstChild != null) {
      _detailPanel.removeChild(_detailPanel.firstChild!);
    }

    final node = _findNodeById(_currentTree, nodeId);
    if (node == null) {
      _addDetailRow('No node selected', '');
      return;
    }

    // General section
    _addDetailSection('General');
    _addDetailRow('Type', node.componentType);
    _addDetailRow('Depth', '${node.depth}');
    _addDetailRow('Stateful', node.isStateful ? 'Yes' : 'No');
    if (node.builtBy != null) _addDetailRow('Built by', node.builtBy!);
    if (node.wasHydrated != null) {
      _addDetailRow('Origin', node.wasHydrated! ? 'Server (hydrated)' : 'Client (dynamic)');
    }
    if (node.sourceLocation != null) {
      _addSourceRow(node.sourceLocation!);
    }

    if (node.hasRenderObject && onInspectInDevTools != null) {
      final btn = web.document.createElement('button') as web.HTMLButtonElement;
      btn.className = 'jaspr-dt-btn jaspr-dt-inspect-btn';
      btn.textContent = '\uD83D\uDD0D Inspect DOM';
      btn.title = 'Reveal in browser DevTools Elements panel';
      btn.addEventListener('click', ((web.Event e) {
        onInspectInDevTools!(nodeId);
      }).toJS);
      _detailPanel.append(btn);
    }

    // DOM section
    if (node.domTag != null) {
      _addDetailSection('DOM');
      _addDetailRow('Tag', node.domTag!);
      if (node.domId != null) _addDetailRow('ID', node.domId!);
      if (node.domClasses != null) _addDetailRow('Classes', node.domClasses!);
      if (node.domAttributes != null && node.domAttributes!.isNotEmpty) {
        for (final entry in node.domAttributes!.entries) {
          _addDetailRow(entry.key, entry.value);
        }
      }
      if (node.eventCount > 0) _addDetailRow('Events', '${node.eventCount}');
    }

    // State section
    if (node.isStateful && node.stateType != null) {
      _addDetailSection('State');
      _addDetailRow('State type', node.stateType!);
      if (node.stateFields != null && node.stateFields!.isNotEmpty) {
        for (final entry in node.stateFields!.entries) {
          _addDetailRow(entry.key, entry.value);
        }
      }
    }

    // Text section
    if (node.textContent != null) {
      _addDetailSection('Text');
      _addDetailRow('Content', node.textContent!);
    }
  }

  void _addDetailSection(String title) {
    final section = web.document.createElement('div') as web.HTMLDivElement;
    section.className = 'jaspr-dt-detail-section';
    section.textContent = title;
    _detailPanel.append(section);
  }

  void _addDetailRow(String label, String value) {
    final row = web.document.createElement('div') as web.HTMLDivElement;
    row.className = 'jaspr-dt-detail-row';

    final labelEl = web.document.createElement('span') as web.HTMLSpanElement;
    labelEl.className = 'jaspr-dt-detail-label';
    labelEl.textContent = label;

    final valueEl = web.document.createElement('span') as web.HTMLSpanElement;
    valueEl.className = 'jaspr-dt-detail-value';
    valueEl.textContent = value;

    row.append(labelEl);
    row.append(valueEl);
    _detailPanel.append(row);
  }

  void _addSourceRow(String source) {
    final row = web.document.createElement('div') as web.HTMLDivElement;
    row.className = 'jaspr-dt-detail-row';

    final labelEl = web.document.createElement('span') as web.HTMLSpanElement;
    labelEl.className = 'jaspr-dt-detail-label';
    labelEl.textContent = 'Source';

    final valueContainer = web.document.createElement('span') as web.HTMLSpanElement;
    valueContainer.className = 'jaspr-dt-source';

    // Show a shortened display path but copy the full path.
    final displaySource = _shortenSourcePath(source);

    final valueEl = web.document.createElement('span') as web.HTMLSpanElement;
    valueEl.className = 'jaspr-dt-detail-value jaspr-dt-source-link';
    valueEl.textContent = displaySource;
    valueEl.title = source;
    valueEl.style.cursor = 'pointer';
    valueEl.addEventListener(
      'click',
      ((web.Event e) {
        _openInIde(source);
      }).toJS,
    );
    valueContainer.append(valueEl);

    final openBtn = web.document.createElement('button') as web.HTMLButtonElement;
    openBtn.className = 'jaspr-dt-btn jaspr-dt-open-btn';
    openBtn.textContent = '\u2197'; // ↗ arrow
    openBtn.title = 'Open in IDE';
    openBtn.addEventListener(
      'click',
      ((web.Event e) {
        _openInIde(source);
      }).toJS,
    );
    valueContainer.append(openBtn);

    final copyBtn = web.document.createElement('button') as web.HTMLButtonElement;
    copyBtn.className = 'jaspr-dt-btn jaspr-dt-copy-btn';
    copyBtn.textContent = '\u2398'; // copy symbol
    copyBtn.title = 'Copy source location';
    copyBtn.addEventListener(
      'click',
      ((web.Event e) {
        web.window.navigator.clipboard.writeText(source);
        copyBtn.textContent = '\u2713'; // checkmark
        Future<void>.delayed(const Duration(milliseconds: 1500), () {
          copyBtn.textContent = '\u2398';
        });
      }).toJS,
    );
    valueContainer.append(copyBtn);

    row.append(labelEl);
    row.append(valueContainer);
    _detailPanel.append(row);
  }

  /// Shortens a `package:foo/path/to/file.dart:42` to `file.dart:42`.
  String _shortenSourcePath(String source) {
    // Extract file name and optional line number from package URI.
    final lastSlash = source.lastIndexOf('/');
    if (lastSlash >= 0) return source.substring(lastSlash + 1);
    return source;
  }

  /// Recursively searches the tree for a node with the given [nodeId].
  InspectorNode? _findNodeById(InspectorNode? node, int nodeId) {
    if (node == null) return null;
    if (node.id == nodeId) return node;
    for (final child in node.children) {
      final found = _findNodeById(child, nodeId);
      if (found != null) return found;
    }
    return null;
  }

  /// Fetches package path mappings from the dev server.
  Future<void> _fetchProjectInfo() async {
    try {
      final response = await web.window.fetch(r'$jasprProjectInfo'.toJS).toDart;
      final jsText = await response.text().toDart;
      final data = jsonDecode(jsText.toDart) as Map<String, dynamic>;
      final packages = data['packages'] as Map<String, dynamic>? ?? {};
      _packagePaths = packages.map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      // Dev server may not support this endpoint — silently ignore.
    }
  }

  /// Opens the given source location in the configured IDE via URL scheme.
  void _openInIde(String source) {
    final ide = web.window.localStorage.getItem('jaspr-dt-ide') ?? 'vscode';

    final parsed = _parseSourceUri(source);
    if (parsed == null) return;

    final libPath = _packagePaths[parsed.package];
    if (libPath == null) return;

    final absolutePath = '$libPath/${parsed.relPath}';
    final line = parsed.line;

    final url = switch (ide) {
      'vscode' => 'vscode://file$absolutePath:$line',
      'cursor' => 'cursor://file$absolutePath:$line',
      'idea' => 'idea://open?file=$absolutePath&line=$line',
      'webstorm' => 'webstorm://open?file=$absolutePath&line=$line',
      _ => null,
    };

    if (url != null) {
      web.window.location.href = url;
    }
  }

  /// Parses `package:foo/path/file.dart:42` or `package:foo/path/file.dart:42:3`
  /// into package name, relative path, and line number.
  ({String package, String relPath, int line})? _parseSourceUri(String source) {
    if (!source.startsWith('package:')) return null;
    final rest = source.substring('package:'.length);
    final slashIdx = rest.indexOf('/');
    if (slashIdx < 0) return null;
    final package = rest.substring(0, slashIdx);
    var pathPart = rest.substring(slashIdx + 1);

    var line = 1;
    final lineMatch = RegExp(r':(\d+)(?::(\d+))?$').firstMatch(pathPart);
    if (lineMatch != null) {
      line = int.parse(lineMatch.group(1)!);
      pathPart = pathPart.substring(0, lineMatch.start);
    }

    return (package: package, relPath: pathPart, line: line);
  }

  /// Shows the settings dialog overlay.
  void _showSettingsDialog() {
    // Remove existing overlay if present.
    final existing = _panel.querySelector('.jaspr-dt-settings-overlay');
    if (existing != null) existing.remove();

    final overlay = web.document.createElement('div') as web.HTMLDivElement;
    overlay.className = 'jaspr-dt-settings-overlay';

    final dialog = web.document.createElement('div') as web.HTMLDivElement;
    dialog.className = 'jaspr-dt-settings-dialog';

    // Title
    final title = web.document.createElement('h3') as web.HTMLHeadingElement;
    title.textContent = 'Inspector Settings';
    dialog.append(title);

    // IDE selector
    final ideLabel = web.document.createElement('label') as web.HTMLLabelElement;
    ideLabel.textContent = 'IDE';
    dialog.append(ideLabel);

    final ideSelect = web.document.createElement('select') as web.HTMLSelectElement;
    final currentIde = web.window.localStorage.getItem('jaspr-dt-ide') ?? 'vscode';
    for (final entry in _kIdeOptions.entries) {
      final option = web.document.createElement('option') as web.HTMLOptionElement;
      option.value = entry.key;
      option.textContent = entry.value;
      if (entry.key == currentIde) option.selected = true;
      ideSelect.append(option);
    }
    dialog.append(ideSelect);

    // Buttons row
    final btnRow = web.document.createElement('div') as web.HTMLDivElement;
    btnRow.style.display = 'flex';
    btnRow.style.justifyContent = 'flex-end';
    btnRow.style.gap = '8px';

    final cancelBtn = web.document.createElement('button') as web.HTMLButtonElement;
    cancelBtn.className = 'jaspr-dt-btn';
    cancelBtn.textContent = 'Cancel';
    cancelBtn.addEventListener(
      'click',
      ((web.Event e) {
        overlay.remove();
      }).toJS,
    );
    btnRow.append(cancelBtn);

    final saveBtn = web.document.createElement('button') as web.HTMLButtonElement;
    saveBtn.className = 'jaspr-dt-btn';
    saveBtn.style.background = '#2d4a7d';
    saveBtn.textContent = 'Save';
    saveBtn.addEventListener(
      'click',
      ((web.Event e) {
        web.window.localStorage.setItem('jaspr-dt-ide', ideSelect.value);
        overlay.remove();
      }).toJS,
    );
    btnRow.append(saveBtn);

    dialog.append(btnRow);
    overlay.append(dialog);

    // Close on overlay background click
    overlay.addEventListener(
      'click',
      ((web.Event e) {
        if (e.target == overlay) overlay.remove();
      }).toJS,
    );

    _panel.append(overlay);
  }

  void _clearSelection() {
    final selected = _root.querySelectorAll('.jaspr-dt-node.selected');
    for (var i = 0; i < selected.length; i++) {
      (selected.item(i)! as web.Element).classList.remove('selected');
    }
  }
}

const _cssText = '''
#jaspr-devtools-root * {
  box-sizing: border-box;
}
#jaspr-devtools-toggle {
  position: fixed;
  bottom: 16px;
  right: 16px;
  z-index: 2147483647;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: none;
  background: #1a1a2e;
  color: #e0e0e0;
  font-size: 20px;
  cursor: pointer;
  box-shadow: 0 2px 8px rgba(0,0,0,0.4);
  display: flex;
  align-items: center;
  justify-content: center;
}
#jaspr-devtools-toggle:hover {
  background: #2a2a4e;
}
#jaspr-devtools-panel {
  position: fixed;
  top: 0;
  right: 0;
  width: 360px;
  height: 100vh;
  z-index: 2147483647;
  background: #1a1a2e;
  color: #e0e0e0;
  font-family: 'SF Mono', 'Fira Code', 'Consolas', monospace;
  font-size: 12px;
  flex-direction: column;
  box-shadow: -2px 0 12px rgba(0,0,0,0.5);
  overflow: hidden;
}
.jaspr-dt-resize {
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 4px;
  cursor: col-resize;
  z-index: 1;
}
.jaspr-dt-resize:hover {
  background: rgba(66, 133, 244, 0.4);
}
.jaspr-dt-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  background: #16162a;
  border-bottom: 1px solid #333;
  font-weight: bold;
  font-size: 13px;
  flex-shrink: 0;
}
.jaspr-dt-btn {
  background: none;
  border: 1px solid #444;
  color: #e0e0e0;
  cursor: pointer;
  padding: 2px 8px;
  margin-left: 4px;
  border-radius: 3px;
  font-size: 14px;
}
.jaspr-dt-btn:hover {
  background: #333;
}
.jaspr-dt-pick-active {
  background: rgba(255, 152, 0, 0.3) !important;
  border-color: #ff9800 !important;
  color: #ff9800 !important;
}
.jaspr-dt-search {
  padding: 4px 8px;
  flex-shrink: 0;
}
.jaspr-dt-search-input {
  width: 100%;
  padding: 4px 8px;
  background: #2a2a4e;
  border: 1px solid #444;
  color: #e0e0e0;
  border-radius: 3px;
  font-size: 12px;
  font-family: inherit;
  outline: none;
}
.jaspr-dt-search-input:focus {
  border-color: #82aaff;
}
.jaspr-dt-tree {
  flex: 1;
  overflow-x: auto;
  overflow-y: auto;
  padding: 8px 0;
  min-height: 0;
  outline: none;
}
.jaspr-dt-node {
  display: flex;
  align-items: center;
  padding: 2px 8px;
  cursor: default;
  white-space: nowrap;
}
.jaspr-dt-node:hover {
  background: rgba(255,255,255,0.05);
}
.jaspr-dt-node.selected {
  background: rgba(66, 133, 244, 0.2);
}
.jaspr-dt-node.search-hidden {
  display: none !important;
}
.jaspr-dt-node.search-match .jaspr-dt-label {
  color: #ff9800;
  font-weight: bold;
}
.jaspr-dt-arrow {
  width: 16px;
  text-align: center;
  cursor: pointer;
  color: #888;
  flex-shrink: 0;
  user-select: none;
}
.jaspr-dt-tag {
  display: inline-block;
  width: 16px;
  height: 16px;
  line-height: 16px;
  text-align: center;
  border-radius: 3px;
  color: #fff;
  font-size: 10px;
  font-weight: bold;
  margin-right: 6px;
  flex-shrink: 0;
}
.jaspr-dt-label {
  cursor: pointer;
  overflow: hidden;
  text-overflow: ellipsis;
}
.jaspr-dt-origin {
  font-size: 9px;
  padding: 0 4px;
  border-radius: 3px;
  color: #fff;
  margin-left: 6px;
  font-weight: bold;
  letter-spacing: 0.5px;
  flex-shrink: 0;
}
.jaspr-dt-label:hover {
  color: #82aaff;
}
.jaspr-dt-children {
  padding-left: 16px;
}
.jaspr-dt-divider {
  height: 3px;
  background: #333;
  cursor: row-resize;
  flex-shrink: 0;
}
.jaspr-dt-divider:hover {
  background: rgba(66, 133, 244, 0.4);
}
.jaspr-dt-detail {
  min-height: 80px;
  max-height: 40vh;
  overflow-y: auto;
  padding: 8px 12px;
  background: #12122a;
  border-top: 1px solid #333;
  flex-shrink: 0;
}
.jaspr-dt-detail-section {
  color: #82aaff;
  font-weight: bold;
  font-size: 11px;
  text-transform: uppercase;
  margin-top: 8px;
  margin-bottom: 4px;
  letter-spacing: 0.5px;
}
.jaspr-dt-detail-section:first-child {
  margin-top: 0;
}
.jaspr-dt-detail-row {
  display: flex;
  padding: 2px 0;
  font-size: 11px;
  line-height: 16px;
}
.jaspr-dt-detail-label {
  color: #888;
  min-width: 80px;
  flex-shrink: 0;
  margin-right: 8px;
}
.jaspr-dt-detail-value {
  color: #e0e0e0;
  word-break: break-all;
}
.jaspr-dt-source {
  display: flex;
  align-items: center;
  gap: 4px;
}
.jaspr-dt-copy-btn {
  font-size: 11px !important;
  padding: 0 4px !important;
  line-height: 16px;
}
.jaspr-dt-source-link {
  color: #82aaff !important;
  cursor: pointer;
}
.jaspr-dt-open-btn {
  color: #82aaff !important;
  font-size: 11px !important;
  padding: 0 4px !important;
  line-height: 16px;
}
.jaspr-dt-inspect-btn {
  margin-top: 4px;
  font-size: 11px !important;
  display: block;
}
.jaspr-dt-settings-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.7);
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: center;
}
.jaspr-dt-settings-dialog {
  background: #1e1e3e;
  border: 1px solid #444;
  border-radius: 6px;
  padding: 16px;
  width: 90%;
  max-width: 320px;
}
.jaspr-dt-settings-dialog h3 {
  margin: 0 0 12px;
  font-size: 13px;
  color: #82aaff;
}
.jaspr-dt-settings-dialog label {
  display: block;
  color: #aaa;
  font-size: 11px;
  margin-bottom: 4px;
}
.jaspr-dt-settings-dialog select,
.jaspr-dt-settings-dialog input[type="text"] {
  width: 100%;
  padding: 6px 8px;
  background: #2a2a4e;
  border: 1px solid #444;
  color: #e0e0e0;
  border-radius: 3px;
  font-size: 12px;
  margin-bottom: 12px;
  font-family: inherit;
}
.jaspr-dt-settings-dialog select:focus,
.jaspr-dt-settings-dialog input:focus {
  border-color: #82aaff;
  outline: none;
}
''';
