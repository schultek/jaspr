import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../styles/theme.dart';

class Dropdown<T> extends StatefulComponent {
  final T? value;
  final Iterable<T> options;
  final ValueChanged<T> onChange;

  final String Function(T?)? getTitle;
  final String Function(T) getLabel;

  const Dropdown({
    required this.value,
    required this.options,
    required this.onChange,
    this.getTitle,
    required this.getLabel,
  });

  @override
  State<Dropdown<T>> createState() => DropdownState<T>();
}

class DropdownState<T> extends State<Dropdown<T>> {
  bool isOpen = false;

  void toggle() {
    setState(() => isOpen = !isOpen);
  }

  void close() {
    if (isOpen) setState(() => isOpen = false);
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'dropdown', [
      button(
        classes: 'dropdown-btn',
        onClick: toggle,
        [
          .text(
            component.getTitle?.call(component.value) ??
                (component.value != null ? component.getLabel(component.value as T) : 'Select...'),
          ),
          span(classes: 'dropdown-chevron', [.text('▼')]),
        ],
      ),
      if (isOpen) div(classes: 'dropdown-backdrop', events: {'click': (_) => close()}, []),
      if (isOpen)
        div(classes: 'dropdown-menu', [
          for (final option in component.options)
            div(
              classes: 'dropdown-item ${option == component.value ? 'selected' : ''}',
              events: {
                'click': (_) {
                  component.onChange(option);
                  close();
                },
              },
              [
                span(classes: 'dropdown-check', [
                  .text(option == component.value ? '✓ ' : '  '),
                ]),
                .text(component.getLabel(option)),
              ],
            ),
        ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.dropdown').styles(
      display: .inlineBlock,
      position: .relative(),
    ),
    css('.dropdown-btn').styles(
      display: .flex,
      padding: .symmetric(horizontal: 12.px, vertical: 5.px),
      border: Border.all(width: 1.px, color: ThemeColors.outlineVariant),
      radius: .circular(ThemeSpacing.r1),
      cursor: .pointer,
      justifyContent: .spaceBetween,
      alignItems: .center,
      color: ThemeColors.onSurface,
      fontSize: 0.75.rem,
      fontWeight: FontWeight.w500,
      backgroundColor: ThemeColors.surfaceContainerHigh,
      raw: {
        'box-shadow': '0 1px 0 rgba(0,0,0,0.1)',
        'white-space': 'nowrap',
      },
    ),
    css('.dropdown-btn:hover').styles(
      backgroundColor: ThemeColors.surfaceContainerHighest,
    ),
    css('.dropdown-chevron').styles(
      margin: .only(left: 8.px),
      opacity: 0.7,
      fontSize: 0.6.rem,
    ),
    css('.dropdown-backdrop').styles(
      position: .fixed(top: 0.px, left: 0.px, right: 0.px, bottom: 0.px),
      zIndex: ZIndex(90),
    ),
    css('.dropdown-menu').styles(
      position: .absolute(top: 100.percent, left: 0.px),
      zIndex: ZIndex(1000),
      minWidth: 160.px,
      padding: .symmetric(vertical: 4.px),
      margin: .only(top: 4.px),
      border: Border.all(width: 1.px, color: ThemeColors.outlineVariant),
      radius: .circular(ThemeSpacing.r1),
      backgroundColor: ThemeColors.surfaceContainerHigh,
      raw: {
        'box-shadow': '0 8px 24px rgba(0,0,0,0.5)',
      },
    ),
    css('.dropdown-item').styles(
      display: .flex,
      padding: .symmetric(horizontal: 8.px, vertical: 6.px),
      cursor: .pointer,
      alignItems: .center,
      color: ThemeColors.onSurface,
      fontSize: 0.75.rem,
      raw: {'white-space': 'nowrap'},
    ),
    css('.dropdown-item:hover').styles(
      color: ThemeColors.background,
      backgroundColor: ThemeColors.primary,
    ),
    css('.dropdown-check').styles(
      display: .inlineBlock,
      width: 16.px,
      margin: .only(right: 4.px),
      raw: {'white-space': 'pre'},
    ),
  ];
}
