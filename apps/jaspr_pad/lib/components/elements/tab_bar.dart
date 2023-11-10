import 'package:jaspr/components.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../adapters/html.dart';
import '../../adapters/mdc.dart';

final tabSelectedProvider = Provider<bool>((ref) => false);
final tabCallbackProvider = Provider<VoidCallback>((ref) => () {});

class TabBar extends StatefulComponent {
  const TabBar(
      {required this.id, required this.selected, required this.onSelected, required this.tabs, this.leading, Key? key})
      : super(key: key);

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
    yield FindChildNode(
      onNodeAttached: (node) {
        if (kIsWeb && _tabBar == null) {
          _tabBar = MDCTabBar(node.nativeElement as ElementOrStubbed)
            ..activateTab(component.selected + (component.leading != null ? 1 : 0));
        }
      },
      child: DomComponent(
        tag: 'div',
        id: component.id,
        classes: ['mdc-tab-bar'],
        styles: Styles.raw({'min-width': '1px'}),
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
                if (component.leading != null) component.leading!,
                for (var i = 0; i < component.tabs.length; i++)
                  ProviderScope(
                    key: ValueKey('tab-provider'),
                    overrides: [
                      tabSelectedProvider.overrideWithValue(i == component.selected),
                      tabCallbackProvider.overrideWithValue(() => _select(i)),
                    ],
                    child: component.tabs[i],
                  ),
              ],
            ),
          ),
        ),
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
    yield DomComponent(
      tag: 'button',
      classes: ['mdc-tab'],
      events: {'click': (e) => onPressed()},
      attributes: {
        'role': 'tab',
        'tabindex': '0',
      },
      styles: Styles.box(padding: EdgeInsets.symmetric(vertical: Unit.zero, horizontal: 16.px)),
      children: [
        DomComponent(
          tag: 'span',
          classes: ['mdc-tab__content'],
          children: [
            DomComponent(
              tag: 'span',
              classes: ['mdc-tab__text-label'],
              styles: Styles.raw({'display': 'inline-flex', 'align-items': 'center'}),
              children: [
                DomComponent(
                  tag: 'i',
                  classes: ['material-icons', 'mdc-tab__icon'],
                  styles: Styles.raw({'font-size': '20px', if (this.label.isNotEmpty) 'margin-right': '4px'}),
                  child: Text(icon),
                ),
                Text(this.label),
              ],
            ),
          ],
        ),
        DomComponent(
          tag: 'span',
          classes: ['mdc-tab-indicator'],
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
