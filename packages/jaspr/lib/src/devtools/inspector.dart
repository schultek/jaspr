import 'dart:js_interop';

import 'package:universal_web/web.dart' as web;

import '../dom/type_checks.dart';
import '../foundation/binding.dart';
import '../foundation/constants.dart';
import 'devtools_service.dart';
import 'embedded_toolbar.dart';
import 'inspector_highlight.dart';

/// Singleton instance to make [initInspector] idempotent.
_JasprInspector? _instance;

/// Initializes the Jaspr DevTools integration.
///
/// In debug mode ([kDebugMode] is `true`), this creates:
/// 1. A [DevToolsService] that exposes the component tree over WebSocket to the
///    standalone DevTools app.
/// 2. An [EmbeddedToolbar] — a minimal floating toolbar for pick mode and quick
///    access to the DevTools app.
///
/// The toolbar can be toggled with **Ctrl+Shift+D**.
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

    _service = DevToolsService(_binding);
    _service.onHighlightRequested = _onHighlightRequested;
    _service.onSelectRequested = _onSelectRequested;

    _toolbar = EmbeddedToolbar(
      onPickModeToggled: _onPickModeChanged,
      devToolsUrl: _devToolsAppUrl,
    );

    // Append to document body.
    final body = web.document.body;
    if (body == null) return;
    body.append(_highlightEl);
    body.append(_toolbar.rootElement);

    // Keyboard shortcut: Ctrl+Shift+D
    _keydownHandler = ((web.KeyboardEvent e) {
      if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key == 'D') {
        e.preventDefault();
        _toolbar.toggle();
      }
    }).toJS;
    web.window.addEventListener('keydown', _keydownHandler);

    // Connect to DevTools relay and start post-frame refresh.
    _service.connect();
    _service.schedulePostFrameRefresh();
  }

  final AppBinding _binding;
  late final DevToolsService _service;
  late final EmbeddedToolbar _toolbar;
  late final InspectorHighlight _highlight;
  late final web.HTMLDivElement _highlightEl;
  late final JSFunction _keydownHandler;

  // Pick mode state.
  bool _pickModeActive = false;
  JSFunction? _pickMouseoverHandler;
  JSFunction? _pickClickHandler;
  JSFunction? _pickKeydownHandler;

  /// The standalone DevTools app URL — derived from the current page origin.
  /// In the future this will be served by the CLI on a configurable port.
  String? get _devToolsAppUrl => null; // TODO: Inject from CLI (Phase 4)

  /// Whether the given DOM node is inside the toolbar.
  bool _isInsideToolbar(web.Node? target) {
    return target != null && _toolbar.rootElement.contains(target);
  }

  void _onHighlightRequested(int nodeId) {
    final element = _service.registry[nodeId];
    if (element != null) {
      final domNode = findDomNodeForElement(element);
      _highlight.highlight(domNode);
    } else {
      _highlight.clear();
    }
  }

  void _onSelectRequested(int nodeId) {
    // Highlight the element on the page when selected from the DevTools app.
    _onHighlightRequested(nodeId);
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

    final body = web.document.body;
    if (body == null) return;

    body.style.cursor = 'crosshair';

    _pickMouseoverHandler = ((web.MouseEvent e) {
      if (_isInsideToolbar(e.target as web.Node?)) return;
      final nodeId = _hitTestDomNode(e.target as web.Node?);
      if (nodeId != null) {
        final element = _service.registry[nodeId];
        if (element != null) {
          final domNode = findDomNodeForElement(element);
          _highlight.highlight(domNode);
        }
      } else {
        _highlight.clear();
      }
    }).toJS;

    _pickClickHandler = ((web.MouseEvent e) {
      if (_isInsideToolbar(e.target as web.Node?)) return;
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();
      final nodeId = _hitTestDomNode(e.target as web.Node?);
      if (nodeId != null) {
        // Notify the DevTools app about the picked element.
        _service.notifyElementPicked(nodeId);
        _onHighlightRequested(nodeId);
      }
      _toolbar.resetPickMode();
      _onPickModeChanged(false);
    }).toJS;

    _pickKeydownHandler = ((web.KeyboardEvent e) {
      if (e.key == 'Escape') {
        _toolbar.resetPickMode();
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

  /// Walks up from [target] through parentElement until finding a node in the
  /// DOM-to-nodeId map.
  int? _hitTestDomNode(web.Node? target) {
    var current = target;
    while (current != null) {
      final nodeId = _service.domNodeMap[current];
      if (nodeId != null) return nodeId;
      if (current.isElement) {
        current = (current as web.Element).parentElement;
      } else {
        current = current.parentNode;
      }
    }
    return null;
  }
}
