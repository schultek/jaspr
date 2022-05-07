import 'package:jaspr/jaspr.dart';

/// Bulma Navbar Component
/// Supports a limited subset of the available options
/// See https://bulma.io/documentation/components/navbar/ for a detailed description
class NavBar extends StatelessComponent {
  const NavBar({this.brand, this.menu, Key? key}) : super(key: key);

  final NavbarBrand? brand;
  final NavbarMenu? menu;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'nav',
      classes: ['navbar', 'block'],
      children: [
        if (brand != null) brand!,
        if (menu != null) menu!,
      ],
    );
  }
}

class NavbarBrand extends StatelessComponent {
  const NavbarBrand({required this.children, Key? key}) : super(key: key);

  final List<Component> children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: ['navbar-brand'],
      children: children,
    );
  }
}

class NavbarMenu extends StatelessComponent {
  const NavbarMenu({required this.items, this.endItems = const [], Key? key}) : super(key: key);

  final List<Component> items;
  final List<Component> endItems;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: ['navbar-menu', 'is-active'],
      children: [
        DomComponent(
          tag: 'div',
          classes: ['navbar-start'],
          children: items,
        ),
        DomComponent(
          tag: 'div',
          classes: ['navbar-end'],
          children: endItems,
        ),
      ],
    );
  }
}

class NavbarItem extends StatelessComponent {
  const NavbarItem({required this.child, this.href, Key? key})
      : items = null,
        super(key: key);

  const NavbarItem.dropdown({required this.child, required this.items, Key? key})
      : href = null,
        super(key: key);

  final Component child;
  final String? href;
  final List<Component>? items;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (items == null) {
      yield DomComponent(
        tag: 'a',
        classes: ['navbar-item'],
        attributes: {if (href != null) 'href': ''},
        child: child,
      );
    } else {
      yield DomComponent(
        tag: 'div',
        classes: ['navbar-item', 'has-dropdown', 'is-hoverable'],
        children: [
          DomComponent(
            tag: 'a',
            classes: ['navbar-link'],
            child: child,
          ),
          DomComponent(
            tag: 'div',
            classes: ['navbar-dropdown'],
            children: items,
          ),
        ],
      );
    }
  }
}

class NavbarDivider extends StatelessComponent {
  const NavbarDivider({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'hr',
      classes: ['navbar-divider'],
    );
  }
}
