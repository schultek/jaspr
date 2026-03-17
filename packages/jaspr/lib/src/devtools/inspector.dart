import 'dart:js_interop';

import 'package:universal_web/web.dart' as web;

import '../dom/type_checks.dart';
import '../foundation/binding.dart';
import '../foundation/constants.dart';
import '../framework/framework.dart';
import 'inspector_highlight.dart';
import 'inspector_panel.dart';
import 'source_resolver.dart';
import 'tree_snapshot.dart';

/// Singleton instance to make [initInspector] idempotent.
_JasprInspector? _instance;

/// Initializes the Jaspr component tree inspector.
///
/// When running in debug mode ([kDebugMode] is `true`), this creates an
/// interactive overlay panel that visualizes the live component tree.
/// The panel can be toggled with **Ctrl+Shift+D** and automatically refreshes
/// after every build cycle while visible.
///
/// This is a no-op in release builds — the entire inspector is tree-shaken
/// because it is gated behind [kDebugMode].
///
/// Safe to call multiple times — only the first call creates the inspector.
void initInspector(AppBinding binding) {
  if (!kDebugMode) return;
  _instance ??= _JasprInspector(binding);
}

class _JasprInspector {
  _JasprInspector(this._binding) {
    _highlightEl = createHighlightElement();
    _highlight = InspectorHighlight(_highlightEl);

    // Initialize source resolver — synchronously builds class→file map from DDC.
    _sourceResolver = SourceResolver();
    // Kick off async line number resolution in the background.
    _sourceResolver.fetchLineNumbers();

    _panel = InspectorPanel(
      onNodeSelected: _onNodeSelected,
      onRefresh: _refreshTree,
      onPickModeChanged: _onPickModeChanged,
      onVisibilityChanged: () => _schedulePostFrameRefresh(),
      onInspectInDevTools: _onInspectInDevTools,
    );

    // Append to document body, guarding against a missing <body>.
    final body = web.document.body;
    if (body == null) return;
    final root = _panel.rootElement;
    root.append(_highlightEl);
    body.append(root);

    // Keyboard shortcut: Ctrl+Shift+D
    _keydownHandler = ((web.KeyboardEvent e) {
      if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key == 'D') {
        e.preventDefault();
        _panel.toggle();
      }
    }).toJS;
    web.window.addEventListener('keydown', _keydownHandler);

    // Register for auto-refresh after each build cycle.
    _schedulePostFrameRefresh();
  }

  final AppBinding _binding;
  late final InspectorPanel _panel;
  late final InspectorHighlight _highlight;
  late final web.HTMLDivElement _highlightEl;
  late final JSFunction _keydownHandler;
  late final SourceResolver _sourceResolver;

  final Map<int, Element> _registry = {};

  /// Cached class → source location map, rebuilt when line numbers become available.
  Map<String, String>? _classLocationsCache;
  bool _classLocationsCacheWithLines = false;

  /// Returns a class name → source location map for tree snapshots.
  Map<String, String>? get _classLocations {
    final hasLines = _sourceResolver.hasLineNumbers;
    if (_classLocationsCache == null || (hasLines && !_classLocationsCacheWithLines)) {
      _classLocationsCache = _sourceResolver.buildClassLocations();
      _classLocationsCacheWithLines = hasLines;
    }
    return _classLocationsCache;
  }

  // Post-frame scheduling guard.
  bool _postFrameScheduled = false;

  // Pick mode state.
  bool _pickModeActive = false;
  Map<web.Node, int> _domNodeMap = {};
  JSFunction? _pickMouseoverHandler;
  JSFunction? _pickClickHandler;
  JSFunction? _pickKeydownHandler;

  /// Whether the given DOM node is inside the inspector panel.
  bool _isInsidePanel(web.Node? target) {
    return target != null && _panel.rootElement.contains(target);
  }

  void _onNodeSelected(int nodeId) {
    final element = _registry[nodeId];
    if (element != null) {
      final domNode = findDomNodeForElement(element);
      _highlight.highlight(domNode);
    } else {
      _highlight.clear();
    }
  }

  void _onInspectInDevTools(int nodeId) {
    final element = _registry[nodeId];
    if (element != null) {
      final domNode = findDomNodeForElement(element);
      inspectInBrowserDevTools(domNode);
    }
  }

  void _refreshTree() {
    final root = _binding.rootElement;
    if (root == null) return;

    _registry.clear();
    final tree = snapshotTree(root, _registry, classLocations: _classLocations);
    _panel.renderTree(tree);

    // Rebuild DOM-to-node-ID map for pick mode.
    _domNodeMap = _buildDomNodeMap();
  }

  Map<web.Node, int> _buildDomNodeMap() {
    final map = <web.Node, int>{};
    for (final entry in _registry.entries) {
      final domNode = findDomNodeForElement(entry.value);
      if (domNode != null) map[domNode] = entry.key;
    }
    return map;
  }

  /// Walks up from [target] through parentElement until finding a node in the
  /// DOM-to-nodeId map.
  int? _hitTestDomNode(web.Node? target) {
    var current = target;
    while (current != null) {
      final nodeId = _domNodeMap[current];
      if (nodeId != null) return nodeId;
      if (current.isElement) {
        current = (current as web.Element).parentElement;
      } else {
        current = current.parentNode;
      }
    }
    return null;
  }

  void _onPickModeChanged(bool active) {
    if (active == _pickModeActive) return;
    _pickModeActive = active;

    if (active) {
      _startPickMode();
    } else {
      _stopPickMode();
    }
  }

  void _startPickMode() {
    _highlight.setPickMode(true);

    // Ensure we have a fresh DOM node map.
    if (_domNodeMap.isEmpty) {
      _domNodeMap = _buildDomNodeMap();
    }

    final body = web.document.body;
    if (body == null) return;

    body.style.cursor = 'crosshair';

    _pickMouseoverHandler = ((web.MouseEvent e) {
      if (_isInsidePanel(e.target as web.Node?)) return;
      final nodeId = _hitTestDomNode(e.target as web.Node?);
      if (nodeId != null) {
        final element = _registry[nodeId];
        if (element != null) {
          final domNode = findDomNodeForElement(element);
          _highlight.highlight(domNode);
        }
      } else {
        _highlight.clear();
      }
    }).toJS;

    _pickClickHandler = ((web.MouseEvent e) {
      if (_isInsidePanel(e.target as web.Node?)) return;
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();
      final nodeId = _hitTestDomNode(e.target as web.Node?);
      if (nodeId != null) {
        _panel.selectAndReveal(nodeId);
        _onNodeSelected(nodeId);
      }
      _panel.setPickMode(false);
      _onPickModeChanged(false);
    }).toJS;

    _pickKeydownHandler = ((web.KeyboardEvent e) {
      if (e.key == 'Escape') {
        _panel.setPickMode(false);
        _onPickModeChanged(false);
      }
    }).toJS;

    body.addEventListener('mouseover', _pickMouseoverHandler!, true.toJS);
    body.addEventListener('click', _pickClickHandler!, true.toJS);
    web.window.addEventListener('keydown', _pickKeydownHandler!);
  }

  void _stopPickMode() {
    _highlight.setPickMode(false);
    _highlight.clear();

    final body = web.document.body;
    if (body != null) {
      body.style.cursor = '';
      if (_pickMouseoverHandler != null) {
        body.removeEventListener('mouseover', _pickMouseoverHandler!, true.toJS);
      }
      if (_pickClickHandler != null) {
        body.removeEventListener('click', _pickClickHandler!, true.toJS);
      }
    }
    if (_pickKeydownHandler != null) {
      web.window.removeEventListener('keydown', _pickKeydownHandler!);
    }
    _pickMouseoverHandler = null;
    _pickClickHandler = null;
    _pickKeydownHandler = null;
  }

  void _schedulePostFrameRefresh() {
    if (_postFrameScheduled) return;
    _postFrameScheduled = true;
    _binding.addPostFrameCallback(() {
      _postFrameScheduled = false;
      if (_panel.isVisible) {
        _refreshTree();
        _schedulePostFrameRefresh();
      }
    });
  }
}
