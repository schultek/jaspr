import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart';

@client
class MenuButton extends StatelessComponent {
  MenuButton({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield button(classes: 'menu-button', onClick: () {
      window.document.querySelector('.sidebar-container')?.classList.toggle('open');
    }, [
      raw(menuIcon),
    ]);
  }

  @css
  static final styles = [
    css('.menu-button').styles(
      display: Display.flex,
      justifyContent: JustifyContent.center,
      alignItems: AlignItems.center,
      width: 2.rem,
      height: 2.rem,
    ),
    css.media(MediaQuery.all(minWidth: 1024.px), [
      css('.menu-button').styles(display: Display.none),
    ]),
  ];
}

const menuIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="4" x2="20" y1="12" y2="12"></line><line x1="4" x2="20" y1="6" y2="6"></line><line x1="4" x2="20" y1="18" y2="18"></line></svg>
''';
