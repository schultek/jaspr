import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:universal_web/web.dart' as web;

import '../client/dom_render_object.dart';
import '../dom/type_checks.dart';
import '../framework/framework.dart';

/// Reveals the given DOM [node] in the browser's DevTools Elements panel.
///
/// Uses Chrome's `inspect()` Console Utilities API when available (requires
/// DevTools to be open). Falls back to `console.dir()` with a stored global
/// reference so the user can inspect from the console.
void inspectInBrowserDevTools(web.Node? node) {
  if (node == null) return;
  // Store on globalThis so users can access via `$jasprNode` in console.
  globalContext['__jasprInspectedNode'] = node as JSAny;
  // Try Chrome's inspect() — only available when DevTools is open.
  final inspect = globalContext['inspect'];
  if (inspect != null && inspect.isA<JSFunction>()) {
    (inspect as JSFunction).callAsFunction(null, node as JSAny);
    return;
  }
  // Fallback: log to console with instructions.
  web.console.log('Jaspr Inspector: selected DOM node ↓'.toJS);
  web.console.dir(node as JSAny);
  web.console.log(
    'Tip: Right-click the element above → "Reveal in Elements panel"'
        ', or open DevTools and run: inspect(__jasprInspectedNode)'
        .toJS,
  );
}

/// Background color of the highlight overlay.
const _kHighlightBackground = 'rgba(66, 133, 244, 0.2)';

/// Border style of the highlight overlay.
const _kHighlightBorder = '2px solid rgba(66, 133, 244, 0.8)';

/// Pick-mode highlight background (orange).
const _kPickHighlightBackground = 'rgba(255, 152, 0, 0.3)';

/// Pick-mode highlight border (orange).
const _kPickHighlightBorder = '2px solid rgba(255, 152, 0, 0.8)';

/// Z-index of the highlight overlay (one below the panel itself).
const _kHighlightZIndex = '2147483646';

/// Finds the nearest DOM node for a given [Element] by walking down to the
/// first [RenderObjectElement] descendant.
web.Node? findDomNodeForElement(Element element) {
  if (element is RenderObjectElement) {
    final ro = element.renderObject;
    if (ro is DomRenderObject) return ro.node;
  }

  // Walk descendants to find the nearest RenderObjectElement.
  web.Node? found;
  element.visitChildren((child) {
    if (found != null) return;
    found = findDomNodeForElement(child);
  });
  return found;
}

/// Manages a fixed-position highlight overlay that can be positioned over any
/// DOM element to visually indicate the selected component.
class InspectorHighlight {
  /// Creates an [InspectorHighlight] backed by the given overlay element.
  InspectorHighlight(this._overlay);

  final web.HTMLDivElement _overlay;
  bool _pickMode = false;

  /// Positions the highlight overlay over [node]. If [node] is not an
  /// `Element` (e.g. a text node), the highlight is cleared.
  void highlight(web.Node? node) {
    if (node == null || !node.isElement) {
      clear();
      return;
    }

    final rect = (node as web.Element).getBoundingClientRect();
    final style = _overlay.style;
    style.display = 'block';
    style.top = '${rect.top + web.window.scrollY}px';
    style.left = '${rect.left + web.window.scrollX}px';
    style.width = '${rect.width}px';
    style.height = '${rect.height}px';
    _applyColors(style);
  }

  /// Switches to pick-mode highlight colors (orange).
  void setPickMode(bool active) {
    _pickMode = active;
    if (_overlay.style.display != 'none') {
      _applyColors(_overlay.style);
    }
  }

  void _applyColors(web.CSSStyleDeclaration style) {
    if (_pickMode) {
      style.background = _kPickHighlightBackground;
      style.border = _kPickHighlightBorder;
    } else {
      style.background = _kHighlightBackground;
      style.border = _kHighlightBorder;
    }
  }

  /// Hides the highlight overlay.
  void clear() {
    _overlay.style.display = 'none';
  }
}

/// Creates the highlight overlay DOM element with appropriate styling.
web.HTMLDivElement createHighlightElement() {
  final el = web.document.createElement('div') as web.HTMLDivElement;
  el.id = 'jaspr-devtools-highlight';
  final style = el.style;
  style.position = 'absolute';
  style.pointerEvents = 'none';
  style.background = _kHighlightBackground;
  style.border = _kHighlightBorder;
  style.zIndex = _kHighlightZIndex;
  style.display = 'none';
  return el;
}
