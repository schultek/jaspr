import 'package:jaspr/jaspr.dart';

/// Bulma Navbar Component
/// Supports a limited subset of the available options
/// See https://bulma.io/documentation/components/navbar/ for a detailed description
class NavBar extends StatelessComponent {
  const NavBar({this.brand, this.menu, super.key});

  final NavbarBrand? brand;
  final NavbarMenu? menu;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield nav(
      classes: 'navbar block',
      [
        if (brand != null) brand!,
        if (menu != null) menu!,
      ],
    );
  }
}

class NavbarBrand extends StatelessComponent {
  const NavbarBrand({required this.children, super.key});

  final List<Component> children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'navbar-brand', children);
  }
}

class NavbarBurger extends StatelessComponent {
  const NavbarBurger({required this.isActive, required this.onToggle});

  final bool isActive;
  final void Function() onToggle;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield a(
      href: "",
      classes: "navbar-burger${isActive ? ' is-active' : ''}",
      attributes: {"role": "button", "data-target": "navMenu"},
      events: events(onClick: () {
        onToggle();
      }),
      [
        span(attributes: {"aria-hidden": "true"}, []),
        span(attributes: {"aria-hidden": "true"}, []),
        span(attributes: {"aria-hidden": "true"}, []),
        span(attributes: {"aria-hidden": "true"}, []),
      ],
    );
  }
}

class NavbarMenu extends StatelessComponent {
  const NavbarMenu({this.isActive = false, required this.items, this.endItems = const [], super.key});

  final bool isActive;
  final List<Component> items;
  final List<Component> endItems;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'navbar-menu${isActive ? ' is-active' : ''}', [
      div(classes: 'navbar-start', items),
      div(classes: 'navbar-end', endItems),
    ]);
  }
}

class NavbarItem extends StatelessComponent {
  const NavbarItem({required this.child, this.href, super.key}) : items = null;

  const NavbarItem.dropdown({required this.child, required this.items, super.key}) : href = null;

  final Component child;
  final String? href;
  final List<Component>? items;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (items == null) {
      yield a(href: href ?? '', classes: 'navbar-item', [child]);
    } else {
      yield div(classes: 'navbar-item has-dropdown is-hoverable', [
        a(href: '', classes: 'navbar-link', [child]),
        div(classes: 'navbar-dropdown', items!),
      ]);
    }
  }
}

class NavbarDivider extends StatelessComponent {
  const NavbarDivider({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield hr(classes: 'navbar-divider');
  }
}
