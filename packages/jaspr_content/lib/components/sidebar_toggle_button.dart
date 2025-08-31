import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' hide Document;

/// A sidebar toggle button.
///
/// When clicked, adds the `open` class to elements with the `.sidebar-container` class.
/// When elements with the `.sidebar-close` or `.sidebar-barrier` class are clicked,
/// removes the `open` class from elements with the `.sidebar-container` class.
@client
final class SidebarToggleButton extends StatelessComponent {
  const SidebarToggleButton({super.key});

  @override
  Component build(BuildContext context) {
    return Component.fragment(children: [
      if (!kIsWeb)
        Document.head(children: [
          Style(styles: _styles),
        ]),
      button(classes: 'sidebar-toggle-button', onClick: () {
        StreamSubscription<void>? closeSub, barrierSub;
        void close(void _) {
          closeSub?.cancel();
          barrierSub?.cancel();
          window.document.querySelector('.sidebar-container')?.classList.remove('open');
        }

        closeSub = window.document.querySelector('.sidebar-close')?.onClick.listen(close);
        barrierSub = window.document.querySelector('.sidebar-barrier')?.onClick.listen(close);
        window.document.querySelector('.sidebar-container')?.classList.add('open');
      }, [
        raw(_menuIcon),
      ]),
    ]);
  }

  List<StyleRule> get _styles => [
        css('.sidebar-toggle-button').styles(
          display: Display.none,
          justifyContent: JustifyContent.center,
          alignItems: AlignItems.center,
          width: 2.rem,
          height: 2.rem,
        ),
        css.media(MediaQuery.all(maxWidth: 1024.px), [
          css('[data-has-sidebar] .sidebar-toggle-button').styles(display: Display.flex),
        ]),
      ];
}

const _menuIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="4" x2="20" y1="12" y2="12"></line><line x1="4" x2="20" y1="6" y2="6"></line><line x1="4" x2="20" y1="18" y2="18"></line></svg>
''';
