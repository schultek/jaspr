import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../theme/devtools_theme.dart';

/// Search/filter bar for the component tree.
class SearchBar extends StatelessComponent {
  const SearchBar({
    required this.onChanged,
    required this.value,
  });

  final void Function(String query) onChanged;
  final String value;

  @override
  Component build(BuildContext context) {
    return div(
      [
        input<String>(
          type: InputType.text,
          value: value,
          onInput: onChanged,
          attributes: {
            'placeholder': 'Filter components...',
          },
          styles: Styles(raw: {
            'width': '100%',
            'background': DevToolsColors.surface,
            'border': '1px solid ${DevToolsColors.border}',
            'border-radius': '4px',
            'padding': '4px 8px',
            'color': DevToolsColors.textPrimary,
            'font-size': '12px',
            'outline': 'none',
            'font-family': 'inherit',
          }),
        ),
      ],
      styles: Styles(raw: {
        'padding': '6px 8px',
        'border-bottom': '1px solid ${DevToolsColors.border}',
      }),
    );
  }
}
