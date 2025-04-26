import 'package:jaspr/jaspr.dart';

import '../jaspr_content.dart';
import '_internal/tab_bar.dart';

/// A tabs component.
class Tabs implements CustomComponent {
  const Tabs();

  static Component from({
    String? defaultValue,
    required List<TabItem> items,
    Key? key,
  }) {
    return _Tabs(defaultValue: defaultValue, items: items, key: key);
  }

  @override
  Component? create(Node node, NodesBuilder builder) {
    if (node is ElementNode && node.tag == 'Tabs') {
      var tabs = node.children?.whereType<ElementNode>().where((n) => n.tag == 'TabItem') ?? [];
      if (tabs.isEmpty) {
        print("[WARNING] Tabs component requires at least one TabItem child.");
      }

      return _Tabs(
        defaultValue: node.attributes['defaultValue'],
        items: [
          for (var tab in tabs)
            TabItem(
              label: tab.attributes['label'] ?? '',
              value: tab.attributes['value'] ?? '',
              child: builder.build(tab.children) ?? const Text(''),
            ),
        ],
      );
    }
    return null;
  }

  @css
  static List<StyleRule> get styles => [
        css('.tabs', [
          css('.tab-content', [
            css('&').styles(display: Display.none),
            css('&[active]').styles(display: Display.initial),
          ])
        ]),
      ];
}

class _Tabs extends StatelessComponent {
  const _Tabs({this.defaultValue, required this.items, super.key});

  /// The default value of the tab.
  final String? defaultValue;

  /// The list of tab items.
  final List<TabItem> items;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final initialValue = defaultValue ?? items.first.value;
    yield div(classes: 'tabs', [
      TabBar(initialValue: initialValue, items: {for (var item in items) item.value: item.label}),
      div([
        for (var item in items)
          div(
            classes: 'tab-content',
            attributes: {'data-tab': item.value, 'label': item.label, if (item.value == initialValue) 'active': ''},
            [item.child],
          ),
      ]),
    ]);
  }
}

class TabItem extends StatelessComponent {
  const TabItem({
    required this.label,
    required this.value,
    required this.child,
    super.key,
  });

  /// The label of the tab.
  final String label;

  /// The value of the tab.
  final String value;

  /// The content of the tab.
  final Component child;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield span(classes: 'tab-item', [text(label)]);
    yield child;
  }
}
