import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/devtools.dart';

import '../theme/devtools_theme.dart';

/// Detail panel showing metadata for the selected component tree node.
class DetailPanel extends StatelessComponent {
  const DetailPanel({required this.node});

  final InspectorNode? node;

  @override
  Component build(BuildContext context) {
    final n = node;
    if (n == null) {
      return div(
        [Component.text('Select a component to inspect')],
        styles: Styles(raw: {
          'display': 'flex',
          'align-items': 'center',
          'justify-content': 'center',
          'height': '100%',
          'color': DevToolsColors.textMuted,
          'font-size': '12px',
          'padding': '16px',
        }),
      );
    }

    return div(
      [
        _sectionTitle(n.componentType),
        if (n.isStateful && n.stateType != null) _row('State', n.stateType!),
        _row('Depth', '${n.depth}'),
        if (n.domTag != null) _row('Tag', '<${n.domTag}>'),
        if (n.domId != null) _row('ID', n.domId!),
        if (n.domClasses != null) _row('Classes', n.domClasses!),
        if (n.eventCount > 0) _row('Events', '${n.eventCount}'),
        if (n.sourceLocation != null) _row('Source', n.sourceLocation!),
        if (n.builtBy != null) _row('Built by', n.builtBy!),
        if (n.wasHydrated != null)
          _row('Origin', n.wasHydrated! ? 'Server (SSR)' : 'Client (CSR)'),
        if (n.textContent != null) _row('Text', n.textContent!),
        if (n.domAttributes != null && n.domAttributes!.isNotEmpty)
          _section('Attributes', n.domAttributes!),
        if (n.stateFields != null && n.stateFields!.isNotEmpty)
          _section('State Fields', n.stateFields!),
      ],
      styles: Styles(raw: {
        'padding': '12px',
        'overflow-y': 'auto',
        'font-size': '12px',
        'line-height': '1.6',
      }),
    );
  }

  Component _sectionTitle(String title) {
    return div(
      [Component.text(title)],
      styles: Styles(raw: {
        'font-weight': '600',
        'font-size': '13px',
        'color': DevToolsColors.textPrimary,
        'margin-bottom': '8px',
        'padding-bottom': '6px',
        'border-bottom': '1px solid ${DevToolsColors.border}',
      }),
    );
  }

  Component _row(String label, String value) {
    return div(
      [
        span(
          [Component.text(label)],
          styles: Styles(raw: {
            'color': DevToolsColors.textSecondary,
            'min-width': '80px',
            'flex-shrink': '0',
          }),
        ),
        span(
          [Component.text(value)],
          styles: Styles(raw: {
            'color': DevToolsColors.textPrimary,
            'word-break': 'break-all',
          }),
        ),
      ],
      styles: Styles(raw: {
        'display': 'flex',
        'gap': '8px',
        'padding': '2px 0',
      }),
    );
  }

  Component _section(String title, Map<String, String> entries) {
    return div(
      [
        div(
          [Component.text(title)],
          styles: Styles(raw: {
            'font-weight': '600',
            'font-size': '11px',
            'color': DevToolsColors.textSecondary,
            'text-transform': 'uppercase',
            'letter-spacing': '0.5px',
            'margin-bottom': '4px',
          }),
        ),
        for (final MapEntry<String, String> entry in entries.entries) _row(entry.key, entry.value),
      ],
      styles: Styles(raw: {'margin-top': '8px'}),
    );
  }
}
