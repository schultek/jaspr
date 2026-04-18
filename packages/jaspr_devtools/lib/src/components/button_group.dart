import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../styles/theme.dart';

class ButtonGroup<T> extends StatelessComponent {
  const ButtonGroup({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.getLabel,
  });

  final List<T> items;
  final T value;
  final ValueChanged<T> onChanged;
  final String Function(T) getLabel;

  @override
  Component build(BuildContext context) {
    return div(classes: 'button-group', [
      for (final v in items)
        button(
          classes: value == v ? 'active' : '',
          onClick: () => onChanged(v),
          [.text(getLabel(v))],
        ),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.button-group', [
      css('&').styles(
        display: .flex,
        border: Border.all(width: 1.px, color: ThemeColors.outlineVariant),
        radius: .circular(ThemeSpacing.r1),
        overflow: .hidden,
        backgroundColor: ThemeColors.surfaceContainerHigh,
        raw: {
          'box-shadow': '0 4px 12px rgba(0,0,0,0.5)',
          'backdrop-filter': 'blur(4px)',
        },
      ),
      css('button').styles(
        padding: .symmetric(horizontal: 10.px, vertical: 4.px),
        border: .none,
        cursor: .pointer,
        transition: Transition('all', duration: 150.ms),
        color: ThemeColors.onSurfaceVariant,
        fontSize: 0.7.rem,
        fontWeight: FontWeight.w500,
        backgroundColor: Colors.transparent,
      ),
      css('button:hover').styles(
        color: ThemeColors.onSurface,
        backgroundColor: ThemeColors.surfaceContainerHighest,
      ),
      css('button.active').styles(
        color: ThemeColors.background,
        fontWeight: FontWeight.bold,
        backgroundColor: ThemeColors.primary,
      ),
    ]),
  ];
}
