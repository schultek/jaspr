import 'package:jaspr/jaspr.dart';

import '../../adapters/html.dart' hide Element;
import '../../adapters/mdc.dart';
import '../utils/node_reader.dart';
import 'button.dart';

class MenuItem extends StatelessComponent {
  const MenuItem({required this.label, super.key});

  final String label;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield li(
      classes: 'mdc-list-item channel-menu-list',
      attributes: {'role': 'menuitem'},
      [
        img(
          classes: 'mdc-list-item__graphic',
          src: 'https://dartpad.dev/pictures/logo_dart.png',
        ),
        span(
          classes: 'mdc-list-item__text',
          [text(label)],
        ),
      ],
    );
  }
}

class Menu extends StatelessComponent {
  const Menu({required this.items, required this.onItemSelected, super.key});

  final List<MenuItem> items;
  final void Function(int) onItemSelected;

  @override
  Iterable<Component> build(BuildContext context) sync* {}

  @override
  Element createElement() => MenuElement(this);
}

class MenuElement extends StatelessElement {
  MenuElement(Menu super.component);

  @override
  Menu get component => super.component as Menu;

  MDCMenuOrStubbed? _menu;
  ElementOrStubbed? _menuNode, _buttonNode;

  void setMenuNodes(ElementOrStubbed? menu, ElementOrStubbed? button) {
    _menuNode ??= menu;
    _buttonNode ??= button;
    if (kIsWeb && _menuNode != null && _buttonNode != null) {
      _menu = MDCMenu(_menuNode!)
        ..setAnchorCorner(AnchorCorner.bottomLeft)
        ..setAnchorElement(_buttonNode!);

      _menu!.listen('MDCMenu:selected', (e) {
        final index = (e as CustomEventOrStubbed).detail['index'] as int;
        component.onItemSelected(index);
      });
    }
  }

  @override
  Iterable<Component> build() sync* {
    yield div(
      styles: Styles.box(position: Position.relative()),
      [
        DomNodeReader(
          onNode: (node) {
            setMenuNodes(null, node);
          },
          child: Button(
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
        ),
        DomNodeReader(
          onNode: (node) {
            setMenuNodes(node, null);
          },
          child: div(
            id: 'samples-menu',
            classes: 'mdc-menu mdc-menu-surface',
            [
              ul(
                classes: 'mdc-list',
                attributes: {'aria-hidden': 'true', 'aria-orientation': 'vertical', 'tabindex': '-1'},
                component.items,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
