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
    yield nav(
      classes: ['navbar', 'block'],
      [
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
    yield div(classes: ['navbar-brand'], children);
  }
}

class NavbarMenu extends StatelessComponent {
  const NavbarMenu({required this.items, this.endItems = const [], Key? key}) : super(key: key);

  final List<Component> items;
  final List<Component> endItems;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(
      classes: ['navbar-menu', 'is-active'],
      [
        div(classes: ['navbar-start'], items),
        div(classes: ['navbar-end'], endItems),
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
      yield a(href: href ?? '', classes: ['navbar-item'], [child]);
    } else {
      yield div(
        classes: ['navbar-item', 'has-dropdown', 'is-hoverable'],
        [
          a(href: '', classes: ['navbar-link'], [child]),
          div(classes: ['navbar-dropdown'], items!),
        ],
      );
    }
  }
}

class NavbarDivider extends StatelessComponent {
  const NavbarDivider({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield hr(classes: ['navbar-divider']);
  }
}
