import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../adapters/mdc.dart';
import '../utils/node_reader.dart';

final _tabProvider = Provider<(bool, int, VoidCallback)>((ref) => (false, 0, () {}));

class TabBar extends StatefulComponent {
  const TabBar({
    required this.id,
    required this.selected,
    required this.onSelected,
    required this.tabs,
    this.leading,
    super.key,
  });

  final String id;
  final int selected;
  final ValueChanged<int> onSelected;
  final List<Tab> tabs;
  final Component? leading;

  @override
  State createState() => TabBarState();
}

class TabBarState extends State<TabBar> {
  MDCTabBarOrStubbed? _tabBar;

  void _select(int tab) {
    component.onSelected(tab);
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomNodeReader(
      onNode: (node) {
        if (kIsWeb && _tabBar == null) {
          _tabBar = MDCTabBar(node)..activateTab(component.selected + (component.leading != null ? 1 : 0));
        }
      },
      child: div(
        id: component.id,
        classes: 'mdc-tab-bar',
        styles: Styles(minWidth: 1.px),
        attributes: {'role': 'tablist'},
        [
          div(classes: 'mdc-tab-scroller', [
            div(classes: 'mdc-tab-scroller__scroll-area', [
              div(classes: 'mdc-tab-scroller__scroll-content', [
                if (component.leading != null) component.leading!,
                for (var i = 0; i < component.tabs.length; i++)
                  ProviderScope(
                    key: ValueKey('tab-provider'),
                    overrides: [
                      _tabProvider.overrideWithValue((i == component.selected, i, () => _select(i))),
                    ],
                    child: component.tabs[i],
                  ),
              ]),
            ]),
          ]),
        ],
      ),
    );
  }
}

class ButtonTab extends Tab {
  ButtonTab({required this.icon, String? label, required this.onPressed}) : super(label: label ?? '');

  final String icon;
  final VoidCallback onPressed;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield button(
      classes: 'mdc-tab',
      events: {'click': (e) => onPressed()},
      attributes: {
        'role': 'tab',
        'tabindex': '0',
      },
      styles: Styles(padding: Padding.symmetric(vertical: Unit.zero, horizontal: 16.px)),
      [
        span(classes: 'mdc-tab__content', [
          span(
            classes: 'mdc-tab__text-label',
            styles: Styles(display: Display.inlineFlex, alignItems: AlignItems.center),
            [
              i(
                classes: 'material-icons mdc-tab__icon',
                styles: Styles(fontSize: 20.px, margin: Margin.only(right: this.label.isNotEmpty ? 4.px : null)),
                [text(icon)],
              ),
              text(this.label),
            ],
          ),
        ]),
        span(classes: 'mdc-tab-indicator', [
          span(classes: 'mdc-tab-indicator__content mdc-tab-indicator__content--underline', []),
        ]),
        span(classes: 'mdc-tab__ripple', []),
      ],
    );
  }
}

class Tab extends StatelessComponent {
  Tab({required this.label, Key? key}) : super(key: key ?? ValueKey('tab-$label'));

  final String label;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var (selected, index, onSelect) = context.watch(_tabProvider);

    yield button(
      classes: 'mdc-tab ${selected ? ' mdc-tab--active' : ''}',
      events: {'click': (e) => onSelect()},
      attributes: {
        'role': 'tab',
        'tabindex': '$index',
        if (selected) 'aria-selected': "true",
      },
      [
        span(classes: 'mdc-tab__content', [
          span(classes: 'mdc-tab__text-label', [text(label)]),
        ]),
        span(classes: 'mdc-tab-indicator ${selected ? ' mdc-tab-indicator--active' : ''}', [
          span(classes: 'mdc-tab-indicator__content mdc-tab-indicator__content--underline', []),
        ]),
        span(classes: 'mdc-tab__ripple', []),
      ],
    );
  }
}
