// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:content_site/components/counter.dart' as prefix0;
import 'package:content_site/main.dart' as prefix1;
import 'package:jaspr_content/components/github_button.dart' as prefix2;
import 'package:jaspr_content/components/menu_button.dart' as prefix3;
import 'package:jaspr_content/components/theme_toggle.dart' as prefix4;

/// Default [JasprOptions] for use with your jaspr project.
///
/// Use this to initialize jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'jaspr_options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultJasprOptions,
///   );
///
///   runApp(...);
/// }
/// ```
JasprOptions get defaultJasprOptions => JasprOptions(
      clients: {
        prefix0.Counter: ClientTarget<prefix0.Counter>('components/counter'),
        prefix2.GithubButton:
            ClientTarget<prefix2.GithubButton>('jaspr_content:components/github_button', params: _prefix2GithubButton),
        prefix3.MenuButton: ClientTarget<prefix3.MenuButton>('jaspr_content:components/menu_button'),
        prefix4.ThemeToggle: ClientTarget<prefix4.ThemeToggle>('jaspr_content:components/theme_toggle'),
      },
      styles: () => [
        ...prefix0.CounterState.styles,
        ...prefix1.Badge.styles,
        ...prefix1.globalStyles,
        ...prefix2.GithubButtonState.styles,
        ...prefix3.MenuButton.styles,
        ...prefix4.ThemeToggleState.styles,
      ],
    );

Map<String, dynamic> _prefix2GithubButton(prefix2.GithubButton c) => {'repo': c.repo};
