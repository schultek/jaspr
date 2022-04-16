import 'package:jaspr/jaspr.dart';

import '../../adapters/mdc.dart';

class TabBar extends StatefulComponent {
  const TabBar({required this.id, Key? key}) : super(key: key);
  final String id;

  @override
  State<StatefulComponent> createState() => TabBarState();

  @override
  Element createElement() => TabBarElement(this);
}

class TabBarState extends State<TabBar> {
  int selectedTab = 0;
  MDCTabBar? _tabBar;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      id: component.id,
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
              Tab(
                id: 'dart-tab',
                label: 'Dart',
                selected: selectedTab == 0,
                onSelect: () {
                  _tabBar?.activateTab(0);
                  setState(() => selectedTab = 0);
                },
              ),
              Tab(
                id: 'html-tab',
                label: 'HTML',
                selected: selectedTab == 1,
                onSelect: () {
                  _tabBar?.activateTab(1);
                  setState(() => selectedTab = 1);
                },
              ),
              Tab(
                id: 'css-tab',
                label: 'CSS',
                selected: selectedTab == 2,
                onSelect: () {
                  _tabBar?.activateTab(2);
                  setState(() => selectedTab = 2);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabBarElement extends StatefulElement {
  TabBarElement(TabBar component) : super(component);

  @override
  TabBarState get state => super.state as TabBarState;

  @override
  void render(DomBuilder b) {
    super.render(b);
    if (kIsWeb) {
      state._tabBar?.destroy();
      state._tabBar = MDCTabBar((children.first as DomElement).source);
    }
  }
}

class Tab extends StatelessComponent {
  const Tab({required this.id, required this.label, this.selected = false, required this.onSelect, Key? key})
      : super(key: key);
  final String id;
  final bool selected;
  final String label;
  final VoidCallback onSelect;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'button',
      classes: ['mdc-tab', if (selected) 'mdc-tab--active'],
      events: {'click': onSelect},
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
