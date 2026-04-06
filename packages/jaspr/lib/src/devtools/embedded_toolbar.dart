import 'dart:js_interop';

import 'package:universal_web/web.dart' as web;

/// A minimal floating toolbar injected into the running page in debug mode.
///
/// Inspired by the Astro Dev Toolbar, this provides quick access to:
/// - Pick mode (select an element on the page to inspect)
/// - Open the standalone DevTools app in a new tab
/// - Component count badge
///
/// The toolbar is intentionally tiny — most functionality lives in the
/// standalone DevTools app served on a separate port.
class EmbeddedToolbar {
  EmbeddedToolbar({
    required this.onPickModeToggled,
    this.devToolsUrl,
  }) {
    _build();
  }

  /// Called when pick mode is toggled on/off.
  final void Function(bool active) onPickModeToggled;

  /// URL of the standalone DevTools app (if available).
  final String? devToolsUrl;

  late final web.HTMLDivElement _root;
  late final web.HTMLButtonElement _pickButton;
  late final web.HTMLButtonElement _devToolsButton;
  late final web.HTMLSpanElement _countBadge;

  bool _visible = false;
  bool _pickMode = false;

  /// The root DOM element of the toolbar.
  web.HTMLDivElement get rootElement => _root;

  /// Whether the toolbar is currently visible.
  bool get isVisible => _visible;

  void _build() {
    _root = web.document.createElement('div') as web.HTMLDivElement;
    _root.id = 'jaspr-devtools-toolbar';
    _applyRootStyles();

    // Pick mode button
    _pickButton = web.document.createElement('button') as web.HTMLButtonElement;
    _pickButton.title = 'Pick element (inspect)';
    _pickButton.innerHTML = _kPickIcon.toJS;
    _applyButtonStyles(_pickButton);
    _pickButton.addEventListener(
      'click',
      ((web.Event _) {
        _pickMode = !_pickMode;
        _pickButton.style.background = _pickMode ? 'rgba(255, 152, 0, 0.3)' : 'transparent';
        onPickModeToggled(_pickMode);
      }).toJS,
    );

    // Open DevTools button
    _devToolsButton = web.document.createElement('button') as web.HTMLButtonElement;
    _devToolsButton.title = 'Open Jaspr DevTools';
    _devToolsButton.innerHTML = _kDevToolsIcon.toJS;
    _applyButtonStyles(_devToolsButton);
    _devToolsButton.addEventListener(
      'click',
      ((web.Event _) {
        final url = devToolsUrl;
        if (url != null) {
          web.window.open(url, '_blank');
        }
      }).toJS,
    );

    // Component count badge
    _countBadge = web.document.createElement('span') as web.HTMLSpanElement;
    _countBadge.textContent = '0';
    final badgeStyle = _countBadge.style;
    badgeStyle.color = '#aaa';
    badgeStyle.fontSize = '11px';
    badgeStyle.padding = '0 6px';
    badgeStyle.lineHeight = '32px';
    badgeStyle.userSelect = 'none';

    _root.append(_pickButton);
    _root.append(_devToolsButton);
    _root.append(_countBadge);
  }

  void _applyRootStyles() {
    final s = _root.style;
    s.position = 'fixed';
    s.bottom = '12px';
    s.left = '50%';
    s.transform = 'translateX(-50%)';
    s.zIndex = '2147483647';
    s.display = 'none'; // hidden by default
    s.alignItems = 'center';
    s.gap = '2px';
    s.background = 'rgba(30, 30, 30, 0.92)';
    s.borderRadius = '20px';
    s.padding = '2px 8px';
    s.boxShadow = '0 2px 12px rgba(0,0,0,0.4)';
    s.fontFamily = '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, monospace';
    s.backdropFilter = 'blur(8px)';
  }

  static void _applyButtonStyles(web.HTMLButtonElement btn) {
    final s = btn.style;
    s.background = 'transparent';
    s.border = 'none';
    s.cursor = 'pointer';
    s.padding = '6px';
    s.borderRadius = '8px';
    s.display = 'flex';
    s.alignItems = 'center';
    s.justifyContent = 'center';
    s.color = '#ccc';
    s.width = '32px';
    s.height = '32px';
  }

  /// Shows the toolbar.
  void show() {
    _visible = true;
    _root.style.display = 'flex';
  }

  /// Hides the toolbar.
  void hide() {
    _visible = false;
    _root.style.display = 'none';
    if (_pickMode) {
      _pickMode = false;
      _pickButton.style.background = 'transparent';
      onPickModeToggled(false);
    }
  }

  /// Toggles toolbar visibility.
  void toggle() {
    if (_visible) {
      hide();
    } else {
      show();
    }
  }

  /// Updates the component count displayed in the badge.
  void updateComponentCount(int count) {
    _countBadge.textContent = '$count';
  }

  /// Resets pick mode state (called externally when pick completes).
  void resetPickMode() {
    _pickMode = false;
    _pickButton.style.background = 'transparent';
  }
}

// SVG icons for toolbar buttons (16x16).
const _kPickIcon = '<svg width="16" height="16" viewBox="0 0 16 16" fill="none">'
    '<path d="M3 3l4 10 1.5-4 4-1.5L3 3z" stroke="currentColor" '
    'stroke-width="1.5" stroke-linejoin="round"/></svg>';

const _kDevToolsIcon = '<svg width="16" height="16" viewBox="0 0 16 16" fill="none">'
    '<rect x="2" y="2" width="12" height="12" rx="2" stroke="currentColor" stroke-width="1.5"/>'
    '<path d="M5 6l2 2-2 2M9 10h2" stroke="currentColor" stroke-width="1.5" '
    'stroke-linecap="round" stroke-linejoin="round"/></svg>';
