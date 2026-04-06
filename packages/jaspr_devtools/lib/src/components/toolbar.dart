import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../theme/devtools_theme.dart';

/// Top toolbar of the DevTools app with refresh and status.
class DevToolsToolbar extends StatelessComponent {
  const DevToolsToolbar({
    required this.onRefresh,
    required this.connected,
    required this.componentCount,
  });

  final VoidCallback onRefresh;
  final bool connected;
  final int componentCount;

  @override
  Component build(BuildContext context) {
    return div(
      [
        // Left: title
        div(
          [
            span(
              [Component.text('Jaspr DevTools')],
              styles: Styles(raw: {
                'font-weight': '600',
                'font-size': '13px',
                'color': DevToolsColors.textPrimary,
              }),
            ),
            span(
              [Component.text('$componentCount components')],
              styles: Styles(raw: {
                'font-size': '11px',
                'color': DevToolsColors.textMuted,
              }),
            ),
          ],
          styles: Styles(raw: {
            'display': 'flex',
            'align-items': 'center',
            'gap': '8px',
          }),
        ),
        // Right: controls
        div(
          [
            // Connection indicator
            span(
              [],
              styles: Styles(raw: {
                'width': '8px',
                'height': '8px',
                'border-radius': '50%',
                'background': connected ? DevToolsColors.accentGreen : DevToolsColors.accentRed,
              }),
            ),
            span(
              [Component.text(connected ? 'Connected' : 'Disconnected')],
              styles: Styles(raw: {
                'font-size': '11px',
                'color': DevToolsColors.textSecondary,
              }),
            ),
            // Refresh button
            button(
              [Component.text('Refresh')],
              onClick: onRefresh,
              styles: Styles(raw: {
                'background': 'transparent',
                'border': '1px solid ${DevToolsColors.border}',
                'border-radius': '4px',
                'padding': '3px 8px',
                'color': DevToolsColors.textPrimary,
                'cursor': 'pointer',
                'font-size': '11px',
                'font-family': 'inherit',
              }),
            ),
          ],
          styles: Styles(raw: {
            'display': 'flex',
            'align-items': 'center',
            'gap': '8px',
          }),
        ),
      ],
      styles: Styles(raw: {
        'display': 'flex',
        'align-items': 'center',
        'justify-content': 'space-between',
        'padding': '6px 12px',
        'background': DevToolsColors.surface,
        'border-bottom': '1px solid ${DevToolsColors.border}',
        'flex-shrink': '0',
      }),
    );
  }
}
