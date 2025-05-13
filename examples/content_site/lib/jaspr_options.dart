// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:content_site/clicker.dart' as prefix0;
import 'package:content_site/main.dart' as prefix1;
import 'package:jaspr_content/components/_internal/code_block_copy_button.dart'
    as prefix2;
import 'package:jaspr_content/components/_internal/tab_bar.dart' as prefix3;
import 'package:jaspr_content/components/_internal/zoomable_image.dart'
    as prefix4;
import 'package:jaspr_content/components/callout.dart' as prefix5;
import 'package:jaspr_content/components/code_block.dart' as prefix6;
import 'package:jaspr_content/components/drop_cap.dart' as prefix7;
import 'package:jaspr_content/components/github_button.dart' as prefix8;
import 'package:jaspr_content/components/image.dart' as prefix9;
import 'package:jaspr_content/components/post_break.dart' as prefix10;
import 'package:jaspr_content/components/sidebar_toggle_button.dart'
    as prefix11;
import 'package:jaspr_content/components/tabs.dart' as prefix12;
import 'package:jaspr_content/components/theme_toggle.dart' as prefix13;

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
    prefix0.Clicker: ClientTarget<prefix0.Clicker>('clicker'),

    prefix2.CodeBlockCopyButton: ClientTarget<prefix2.CodeBlockCopyButton>(
      'jaspr_content:components/_internal/code_block_copy_button',
    ),

    prefix3.TabBar: ClientTarget<prefix3.TabBar>(
      'jaspr_content:components/_internal/tab_bar',
      params: _prefix3TabBar,
    ),

    prefix4.ZoomableImage: ClientTarget<prefix4.ZoomableImage>(
      'jaspr_content:components/_internal/zoomable_image',
      params: _prefix4ZoomableImage,
    ),

    prefix8.GithubButton: ClientTarget<prefix8.GithubButton>(
      'jaspr_content:components/github_button',
      params: _prefix8GithubButton,
    ),

    prefix11.SidebarToggleButton: ClientTarget<prefix11.SidebarToggleButton>(
      'jaspr_content:components/sidebar_toggle_button',
    ),

    prefix13.ThemeToggle: ClientTarget<prefix13.ThemeToggle>(
      'jaspr_content:components/theme_toggle',
    ),
  },
  styles:
      () => [
        ...prefix1.globalStyles,
        ...prefix3.TabBar.styles,
        ...prefix4.ZoomableImage.styles,
        ...prefix5.Callout.styles,
        ...prefix6.CodeBlock.styles,
        ...prefix7.DropCap.styles,
        ...prefix8.GithubButtonState.styles,
        ...prefix9.Image.styles,
        ...prefix10.PostBreak.styles,
        ...prefix12.Tabs.styles,
        ...prefix13.ThemeToggleState.styles,
      ],
);

Map<String, dynamic> _prefix3TabBar(prefix3.TabBar c) => {
  'initialValue': c.initialValue,
  'items': c.items,
};
Map<String, dynamic> _prefix4ZoomableImage(prefix4.ZoomableImage c) => {
  'src': c.src,
  'alt': c.alt,
  'caption': c.caption,
};
Map<String, dynamic> _prefix8GithubButton(prefix8.GithubButton c) => {
  'repo': c.repo,
};
