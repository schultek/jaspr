// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:content_site/main.dart' as prefix0;
import 'package:jaspr_content/components/_internal/zoomable_image.dart' as prefix1;
import 'package:jaspr_content/components/callout.dart' as prefix2;
import 'package:jaspr_content/components/drop_cap.dart' as prefix3;
import 'package:jaspr_content/components/github_button.dart' as prefix4;
import 'package:jaspr_content/components/image.dart' as prefix5;
import 'package:jaspr_content/components/post_break.dart' as prefix6;
import 'package:jaspr_content/components/sidebar_toggle_button.dart' as prefix7;
import 'package:jaspr_content/components/theme_toggle.dart' as prefix8;

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
        prefix1.ZoomableImage: ClientTarget<prefix1.ZoomableImage>('jaspr_content:components/_internal/zoomable_image',
            params: _prefix1ZoomableImage),
        prefix4.GithubButton:
            ClientTarget<prefix4.GithubButton>('jaspr_content:components/github_button', params: _prefix4GithubButton),
        prefix7.SidebarToggleButton:
            ClientTarget<prefix7.SidebarToggleButton>('jaspr_content:components/sidebar_toggle_button'),
        prefix8.ThemeToggle: ClientTarget<prefix8.ThemeToggle>('jaspr_content:components/theme_toggle'),
      },
      styles: () => [
        ...prefix0.globalStyles,
        ...prefix1.ZoomableImage.styles,
        ...prefix2.Callout.styles,
        ...prefix3.DropCap.styles,
        ...prefix4.GithubButtonState.styles,
        ...prefix5.Image.styles,
        ...prefix6.PostBreak.styles,
        ...prefix8.ThemeToggleState.styles,
      ],
    );

Map<String, dynamic> _prefix1ZoomableImage(prefix1.ZoomableImage c) =>
    {'src': c.src, 'alt': c.alt, 'caption': c.caption};
Map<String, dynamic> _prefix4GithubButton(prefix4.GithubButton c) => {'repo': c.repo};
