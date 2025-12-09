// [sample=6] Bulma CSS
import 'package:jaspr/dom.dart' hide Color;
import 'package:jaspr/jaspr.dart';

import 'button.dart';
import 'colors.dart';
import 'navbar.dart';
import 'progress_bar.dart';
import 'tabs.dart';

void main() {
  runApp(App());
}

class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return .fragment([
      ExampleNavbar(),
      ButtonGroup(
        children: [
          Button(child: .text('Normal'), onPressed: () {}),
          Button(child: .text('Outlined'), isOutlined: true, onPressed: () {}),
          Button(child: .text('Primary'), color: Color.primary, onPressed: () {}),
          Button(child: .text('Loading'), isLoading: true, onPressed: () {}),
        ],
      ),
      ButtonGroup(
        isAttached: true,
        children: [
          Button(
            child: IconLabel(icon: 'align-left', label: 'Left'),
            onPressed: () {},
          ),
          Button(
            child: IconLabel(icon: 'align-center', label: 'Center'),
            onPressed: () {},
          ),
          Button(
            child: IconLabel(icon: 'align-right', label: 'Right'),
            onPressed: () {},
          ),
        ],
      ),
      ProgressBar(value: 70, color: Color.success),
      ProgressBar(color: Color.warning),
      Tabs(
        tabs: [.text('Pictures'), .text('Music'), .text('Videos'), .text('Documents')],
        onSelected: (int value) {},
      ),
      Tabs(
        tabs: [
          IconLabel(icon: 'image', label: 'Pictures'),
          IconLabel(icon: 'music', label: 'Music'),
          IconLabel(icon: 'film', label: 'Videos'),
          IconLabel(icon: 'file-alt', label: 'Documents'),
        ],
        isToggle: true,
        onSelected: (int value) {},
      ),
    ]);
  }
}

class ExampleNavbar extends StatefulComponent {
  const ExampleNavbar({super.key});

  @override
  State<ExampleNavbar> createState() => _ExampleNavbarState();
}

class _ExampleNavbarState extends State<ExampleNavbar> {
  bool isActive = false;

  @override
  Component build(BuildContext context) {
    return NavBar(
      brand: NavbarBrand(
        children: [
          NavbarItem(child: BulmaLogo(), href: 'https://bulma.io'),
          NavbarBurger(
            isActive: isActive,
            onToggle: () {
              setState(() => isActive = !isActive);
            },
          ),
        ],
      ),
      menu: NavbarMenu(
        isActive: isActive,
        items: [
          NavbarItem(child: .text('Home')),
          NavbarItem(child: .text('Documentation')),
          NavbarItem.dropdown(
            child: .text('More'),
            items: [
              NavbarItem(child: .text('About')),
              NavbarItem(child: .text('Jobs')),
              NavbarItem(child: .text('Contact')),
              NavbarDivider(),
              NavbarItem(child: .text('Report an issue')),
            ],
          ),
        ],
      ),
    );
  }
}

class BulmaLogo extends StatelessComponent {
  const BulmaLogo({super.key});

  @override
  Component build(BuildContext context) {
    return img(src: 'https://bulma.io/assets/brand/Bulma%20Logo.svg', attributes: {'width': '112', 'height': '20'});
  }
}
