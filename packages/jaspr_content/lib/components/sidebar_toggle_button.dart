import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' hide Document;

/// A sidebar toggle button.
@client
class SidebarToggleButton extends StatelessComponent {
  SidebarToggleButton({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (!kIsWeb) {
      yield Document.head(
        children: [
          Style(styles: styles),
        ],
      );
    }

    yield button(
      classes: 'sidebar-toggle-button',
      onClick: () {
        StreamSubscription? closeSub, barrierSub;
        void close() {
          closeSub?.cancel();
          barrierSub?.cancel();
          window.document
              .querySelector('.sidebar-container')
              ?.classList
              .remove('open');
        }

        closeSub = window.document
            .querySelector('.sidebar-close')
            ?.onClick
            .listen((_) {
              close();
            });
        barrierSub = window.document
            .querySelector('.sidebar-barrier')
            ?.onClick
            .listen((_) {
              close();
            });
        window.document
            .querySelector('.sidebar-container')
            ?.classList
            .add('open');
      },
      [
        raw(menuIcon),
      ],
    );
  }

  List<StyleRule> get styles => [
    css('.sidebar-toggle-button').styles(
      display: Display.none,
      justifyContent: JustifyContent.center,
      alignItems: AlignItems.center,
      width: 2.rem,
      height: 2.rem,
    ),
    css.media(MediaQuery.all(maxWidth: 1024.px), [
      css(
        '[data-has-sidebar] .sidebar-toggle-button',
      ).styles(display: Display.flex),
    ]),
  ];
}

const menuIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="4" x2="20" y1="12" y2="12"></line><line x1="4" x2="20" y1="6" y2="6"></line><line x1="4" x2="20" y1="18" y2="18"></line></svg>
''';
