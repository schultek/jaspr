import 'package:jaspr/jaspr.dart';

/// Bulma Tabs Component
/// Supports a limited subset of the available options
/// See https://bulma.io/documentation/components/tabs/ for a detailed description
class Tabs extends StatefulComponent {
  const Tabs({required this.tabs, required this.onSelected, this.isBoxed = false, this.isToggle = false, super.key});

  final List<Component> tabs;
  final ValueChanged<int> onSelected;
  final bool isBoxed;
  final bool isToggle;

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  var selected = 0;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: [
      'tabs',
      if (component.isBoxed) 'is-boxed',
      if (component.isToggle) 'is-toggle'
    ], [
      ul([
        for (var i = 0; i < component.tabs.length; i++)
          Tab(
            selected: i == selected,
            onSelected: () {
              setState(() => selected = i);
              component.onSelected(i);
            },
            child: component.tabs[i],
          ),
      ]),
    ]);
  }
}

class Tab extends StatelessComponent {
  const Tab({required this.selected, required this.onSelected, required this.child, super.key});

  final bool selected;
  final VoidCallback onSelected;
  final Component child;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield li(
      classes: [if (selected) 'is-active'],
      events: {'click': (e) => onSelected()},
      [
        a(href: '', [child])
      ],
    );
  }
}
