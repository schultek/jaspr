import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import '../../src/theme/theme.dart';

@client
class TabBar extends StatefulComponent {
  const TabBar({required this.initialValue, required this.items, super.key});

  /// The default value of the tab.
  final String initialValue;

  /// The list of tab items.
  final Map<String, String> items;

  @override
  State<TabBar> createState() => _TabBarState();

  @css
  static List<StyleRule> get styles => [
    css('.tab-bar', [
      css('&').styles(
        display: Display.flex,
        alignItems: AlignItems.center,
        gap: Gap.column(1.25.rem),
        border: Border.only(
          bottom: BorderSide(width: 1.px, color: ContentColors.hr),
        ),
      ),
      css('button').styles(
        padding: Padding.symmetric(vertical: 0.75.rem),
        fontWeight: FontWeight.w700,
        border: Border.only(
          bottom: BorderSide(width: 2.px, color: Colors.transparent),
        ),
      ),
      css('button:hover').styles(raw: {'border-bottom-color': ContentColors.hr.value}),
      css(
        'button[active]',
      ).styles(color: ContentColors.primary, raw: {'border-bottom-color': ContentColors.primary.value}),
    ]),
  ];
}

class _TabBarState extends State<TabBar> {
  late String value;

  @override
  void initState() {
    super.initState();
    value = component.initialValue;
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'tab-bar', [
      for (var item in component.items.entries)
        button(
          attributes: {if (item.key == value) 'active': ''},
          events: {
            'click': (e) {
              setState(() {
                value = item.key;
              });

              final target = e.currentTarget as web.Element;

              final currentTabView = target.parentElement?.nextElementSibling?.querySelector('div[active]');
              final nexttabView = target.parentElement?.nextElementSibling?.querySelector(
                'div[data-tab="${item.key}"]',
              );

              currentTabView?.removeAttribute('active');
              nexttabView?.setAttribute('active', '');
            },
          },
          [Component.text(item.value)],
        ),
    ]);
  }
}
