import 'package:jaspr/dom.dart';

import '../src/page_parser/page_parser.dart';
import '_internal/icon.dart';

/// A custom callout component.
///
/// Can be one of 'Info', 'Warning', 'Error', or 'Success'.
class Callout extends CustomComponentBase {
  Callout();

  static Component from({required String type, required Component child, Key? key}) {
    return _Callout(type: type.toLowerCase(), child: child, key: key);
  }

  @override
  final Pattern pattern = RegExp(r'Info|Warning|Error|Success');

  @override
  Component apply(String name, Map<String, String> attributes, Component? child) {
    return _Callout(type: name.toLowerCase(), child: child!);
  }

  @css
  static List<StyleRule> get styles => [
    css('.callout', [
      css('&').styles(
        display: Display.flex,
        padding: Padding.symmetric(vertical: 1.rem, horizontal: 1.25.rem),
        margin: Margin.only(bottom: 0.75.rem),
        radius: BorderRadius.circular(0.75.rem),
        border: Border.all(width: 1.px),
        gap: Gap.column(1.rem),
      ),
      css('span:first-child').styles(
        padding: Padding.only(top: 0.25.rem),
        flex: Flex(shrink: 0),
      ),
      css('span:last-child > p').styles(margin: Margin.all(Unit.zero)),
      css('&.callout-info').styles(
        color: Color('rgb(3 105 161)'),
        backgroundColor: Color('rgba(186, 230, 253, .1)'),
        border: Border.all(color: Color('rgba(14,165,233,.2)')),
      ),
      css('&.callout-warning').styles(
        color: Color('rgb(161 98 7)'),
        backgroundColor: Color('hsla(53,98%,77%,.1)'),
        border: Border.all(color: Color('rgba(234,179,8,.2)')),
      ),
      css('&.callout-error').styles(
        color: Color('rgb(185 28 28)'),
        backgroundColor: Color('hsla(0,96%,89%,.1)'),
        border: Border.all(color: Color('rgba(239,68,68,.2)')),
      ),
      css('&.callout-success').styles(
        color: Color('oklch(0.527 0.154 150.069)'),
        backgroundColor: Color('rgba(187,247,208,.1)'),
        border: Border.all(color: Color('rgba(34,197,94,.2)')),
      ),
    ]),
    css('[data-theme="dark"] .callout', [
      css('&.callout-info').styles(
        color: Color.inherit,
        backgroundColor: Color('rgba(14,165,233,.1)'),
        border: Border.all(color: Color('rgba(14,165,233,.5)')),
      ),
      css('&.callout-warning').styles(
        color: Color.inherit,
        backgroundColor: Color('rgba(234,179,8,.1)'),
        border: Border.all(color: Color('rgba(234,179,8,.5)')),
      ),
      css('&.callout-error').styles(
        color: Color.inherit,
        backgroundColor: Color('rgba(239,68,68,.1)'),
        border: Border.all(color: Color('rgba(239,68,68,.5)')),
      ),
      css('&.callout-success').styles(
        color: Color.inherit,
        backgroundColor: Color('rgba(34,197,94,.1)'),
        border: Border.all(color: Color('rgba(34,197,94,.5)')),
      ),
    ]),
  ];
}

/// A callout component.
///
/// Can be one of 'Info', 'Warning', 'Error', or 'Success'.
class _Callout extends StatelessComponent {
  const _Callout({required this.type, required this.child, super.key});

  final String type;
  final Component child;

  @override
  Component build(BuildContext context) {
    return div(classes: 'callout callout-$type', [
      span([
        switch (type) {
          'info' => InfoIcon(size: 20),
          'warning' => AlertIcon(size: 20),
          'error' => CircleXIcon(size: 20),
          'success' => CircleCheckIcon(size: 20),
          _ => InfoIcon(size: 20),
        },
      ]),
      span([child]),
    ]);
  }
}
