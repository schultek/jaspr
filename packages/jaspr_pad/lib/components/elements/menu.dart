import 'package:jaspr/jaspr.dart';

import '../../adapters/mdc.dart';
import 'button.dart';

class MenuItem extends StatelessComponent {
  const MenuItem({required this.label, Key? key}) : super(key: key);

  final String label;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'li',
      classes: ['mdc-list-item', 'channel-menu-list'],
      attributes: {'role': 'menuitem'},
      children: [
        DomComponent(
          tag: 'img',
          classes: ['mdc-list-item__graphic'],
          attributes: {'src': 'https://dartpad.dev/pictures/logo_dart.png'},
        ),
        DomComponent(
          tag: 'span',
          classes: ['mdc-list-item__text'],
          child: Text(label),
        ),
      ],
    );
  }
}

class Menu extends StatelessComponent {
  const Menu({required this.items, required this.onItemSelected, Key? key}) : super(key: key);

  final List<MenuItem> items;
  final void Function(int) onItemSelected;

  @override
  Iterable<Component> build(BuildContext context) sync* {}

  @override
  Element createElement() => MenuElement(this);
}

class MenuElement extends StatelessElement {
  MenuElement(Menu component) : super(component);

  @override
  Menu get component => super.component as Menu;

  MDCMenu? _menu;

  @override
  Iterable<Component> build() sync* {
    yield DomComponent(
      tag: 'div',
      styles: {'position': 'relative'},
      children: [
        Button(
          id: 'samples-dropdown-button',
          label: 'Samples',
          icon: 'expand_more',
          hideIcon: true,
          iconAffinity: IconAffinity.right,
          onPressed: () {
            if (_menu != null) {
              _menu!.open = !(_menu!.open ?? false);
            }
          },
        ),
        DomComponent(
          tag: 'div',
          id: 'samples-menu',
          classes: ['mdc-menu', 'mdc-menu-surface'],
          children: [
            DomComponent(
              tag: 'ul',
              classes: ['mdc-list'],
              attributes: {'aria-hidden': 'true', 'aria-orientation': 'vertical', 'tabindex': '-1'},
              children: component.items,
            ),
          ],
        ),
      ],
    );
  }

  @override
  void render(DomBuilder b) {
    if (_menu == null) {
      super.render(b);
      if (kIsWeb) {
        DomElement? menuElement, buttonElement;

        void childVisitor(Element element) {
          if (element is DomElement) {
            if (buttonElement == null) {
              buttonElement = element;
            } else {
              menuElement = element;
            }
          } else {
            element.visitChildren(childVisitor);
          }
        }

        children.first.visitChildren(childVisitor);

        _menu = MDCMenu(menuElement!.source)
          ..setAnchorCorner(AnchorCorner.bottomLeft)
          ..setAnchorElement(buttonElement!.source);

        _menu!.listen('MDCMenu:selected', (e) {
          final index = (e as CustomEvent).detail['index'] as int;
          component.onItemSelected(index);
        });
      }
    } else {
      b.skipNode();
    }
  }
}
