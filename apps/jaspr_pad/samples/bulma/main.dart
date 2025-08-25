// [sample=6] Bulma CSS
import 'package:jaspr/jaspr.dart' hide Color;

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
    return Fragment(children: [
      ExampleNavbar(),
      ButtonGroup(children: [
        Button(child: Text('Normal'), onPressed: () {}),
        Button(child: Text('Outlined'), isOutlined: true, onPressed: () {}),
        Button(child: Text('Primary'), color: Color.primary, onPressed: () {}),
        Button(child: Text('Loading'), isLoading: true, onPressed: () {}),
      ]),
      ButtonGroup(isAttached: true, children: [
        Button(child: IconLabel(icon: 'align-left', label: 'Left'), onPressed: () {}),
        Button(child: IconLabel(icon: 'align-center', label: 'Center'), onPressed: () {}),
        Button(child: IconLabel(icon: 'align-right', label: 'Right'), onPressed: () {}),
      ]),
      ProgressBar(value: 70, color: Color.success),
      ProgressBar(color: Color.warning),
      Tabs(
        tabs: [Text('Pictures'), Text('Music'), Text('Videos'), Text('Documents')],
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
      brand: NavbarBrand(children: [
        NavbarItem(child: BulmaLogo(), href: 'https://bulma.io'),
        NavbarBurger(
          isActive: isActive,
          onToggle: () {
            setState(() => isActive = !isActive);
          },
        ),
      ]),
      menu: NavbarMenu(isActive: isActive, items: [
        NavbarItem(child: Text('Home')),
        NavbarItem(child: Text('Documentation')),
        NavbarItem.dropdown(child: Text('More'), items: [
          NavbarItem(child: Text('About')),
          NavbarItem(child: Text('Jobs')),
          NavbarItem(child: Text('Contact')),
          NavbarDivider(),
          NavbarItem(child: Text('Report an issue')),
        ]),
      ]),
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
