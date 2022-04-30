import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../adapters/mdc.dart';

final tabSelectedProvider = Provider<bool>((ref) => false);
final tabCallbackProvider = Provider<VoidCallback>((ref) => () {});

class TabBar extends StatelessComponent {
  const TabBar({required this.id, required this.selected, required this.onSelected, required this.tabs, Key? key})
      : super(key: key);

  final String id;
  final int selected;
  final ValueChanged<int> onSelected;
  final List<Tab> tabs;

  void _select(int tab) {
    onSelected(tab);
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      id: id,
      classes: ['mdc-tab-bar'],
      attributes: {'role': 'tablist'},
      child: DomComponent(
        tag: 'div',
        classes: ['mdc-tab-scroller'],
        child: DomComponent(
          tag: 'div',
          classes: ['mdc-tab-scroller__scroll-area'],
          child: DomComponent(
            tag: 'div',
            classes: ['mdc-tab-scroller__scroll-content'],
            children: [
              for (var i = 0; i < tabs.length; i++)
                ProviderScope(
                    key: ValueKey('tab-provider'),
                    overrides: [
                      tabSelectedProvider.overrideWithValue(i == selected),
                      tabCallbackProvider.overrideWithValue(() => _select(i)),
                    ],
                    child: tabs[i]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Element createElement() => TabBarElement(this);
}

class TabBarElement extends StatelessElement {
  TabBarElement(TabBar component) : super(component);

  @override
  TabBar get component => super.component as TabBar;

  MDCTabBar? _tabBar;

  @override
  void render(DomBuilder b) {
    super.render(b);

    if (kIsWeb) {
      _tabBar?.destroy();
      var tabBarRoot = (children.first as DomElement).source;
      _tabBar = MDCTabBar(tabBarRoot)..activateTab(component.selected);
    }
  }
}

class ButtonTab extends Tab {
  ButtonTab({required this.icon, String? label, required this.onPressed}) : super(label: label ?? '');

  final String icon;
  final VoidCallback onPressed;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'button',
      classes: ['mdc-tab'],
      events: {'click': (e) => onPressed()},
      attributes: {
        'role': 'tab',
        'tabindex': '0',
      },
      styles: {'padding': '0 16px'},
      children: [
        DomComponent(
          tag: 'span',
          classes: ['mdc-tab__content'],
          children: [
            DomComponent(
              tag: 'span',
              classes: ['mdc-tab__text-label'],
              styles: {'display': 'inline-flex', 'align-items': 'center'},
              children: [
                DomComponent(
                  tag: 'i',
                  classes: ['material-icons', 'mdc-tab__icon'],
                  styles: {'font-size': '20px', if (label.isNotEmpty) 'margin-right': '4px'},
                  child: Text(icon),
                ),
                Text(label),
              ],
            ),
          ],
        ),
        DomComponent(
          tag: 'span',
          classes: ['mdc-tab__ripple'],
        ),
      ],
    );
  }
}

class Tab extends StatelessComponent {
  Tab({required this.label, Key? key}) : super(key: key ?? ValueKey('tab-$label'));

  final String label;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var selected = context.watch(tabSelectedProvider);
    var onSelect = context.watch(tabCallbackProvider);

    yield DomComponent(
      tag: 'button',
      classes: ['mdc-tab', if (selected) 'mdc-tab--active'],
      events: {'click': (e) => onSelect()},
      attributes: {
        'role': 'tab',
        'tabindex': '0',
        if (selected) 'aria-selected': "true",
      },
      children: [
        DomComponent(
          tag: 'span',
          classes: ['mdc-tab__content'],
          children: [
            DomComponent(
              tag: 'span',
              classes: ['mdc-tab__text-label'],
              child: Text(label),
            ),
          ],
        ),
        DomComponent(
          tag: 'span',
          classes: ['mdc-tab-indicator', if (selected) 'mdc-tab-indicator--active'],
          children: [
            DomComponent(
              tag: 'span',
              classes: ['mdc-tab-indicator__content', 'mdc-tab-indicator__content--underline'],
            ),
          ],
        ),
        DomComponent(
          tag: 'span',
          classes: ['mdc-tab__ripple'],
        ),
      ],
    );
  }
}
