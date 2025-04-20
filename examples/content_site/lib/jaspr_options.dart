// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:content_site/main.dart' as prefix0;
import 'package:jaspr_content/components/_internal/code_block_copy_button.dart'
    as prefix1;
import 'package:jaspr_content/components/_internal/tab_bar.dart' as prefix2;
import 'package:jaspr_content/components/_internal/zoomable_image.dart'
    as prefix3;
import 'package:jaspr_content/components/callout.dart' as prefix4;
import 'package:jaspr_content/components/code_block.dart' as prefix5;
import 'package:jaspr_content/components/drop_cap.dart' as prefix6;
import 'package:jaspr_content/components/github_button.dart' as prefix7;
import 'package:jaspr_content/components/image.dart' as prefix8;
import 'package:jaspr_content/components/post_break.dart' as prefix9;
import 'package:jaspr_content/components/sidebar_toggle_button.dart'
    as prefix10;
import 'package:jaspr_content/components/tabs.dart' as prefix11;
import 'package:jaspr_content/components/theme_toggle.dart' as prefix12;

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
    prefix1.CodeBlockCopyButton: ClientTarget<prefix1.CodeBlockCopyButton>(
      'jaspr_content:components/_internal/code_block_copy_button',
    ),

    prefix2.TabBar: ClientTarget<prefix2.TabBar>(
      'jaspr_content:components/_internal/tab_bar',
      params: _prefix2TabBar,
    ),

    prefix3.ZoomableImage: ClientTarget<prefix3.ZoomableImage>(
      'jaspr_content:components/_internal/zoomable_image',
      params: _prefix3ZoomableImage,
    ),

    prefix7.GithubButton: ClientTarget<prefix7.GithubButton>(
      'jaspr_content:components/github_button',
      params: _prefix7GithubButton,
    ),

    prefix10.SidebarToggleButton: ClientTarget<prefix10.SidebarToggleButton>(
      'jaspr_content:components/sidebar_toggle_button',
    ),

    prefix12.ThemeToggle: ClientTarget<prefix12.ThemeToggle>(
      'jaspr_content:components/theme_toggle',
    ),
  },
  styles:
      () => [
        ...prefix0.globalStyles,
        ...prefix2.TabBar.styles,
        ...prefix3.ZoomableImage.styles,
        ...prefix4.Callout.styles,
        ...prefix5.CodeBlock.styles,
        ...prefix6.DropCap.styles,
        ...prefix7.GithubButtonState.styles,
        ...prefix8.Image.styles,
        ...prefix9.PostBreak.styles,
        ...prefix11.Tabs.styles,
        ...prefix12.ThemeToggleState.styles,
      ],
);

Map<String, dynamic> _prefix2TabBar(prefix2.TabBar c) => {
  'initialValue': c.initialValue,
  'items': c.items,
};
Map<String, dynamic> _prefix3ZoomableImage(prefix3.ZoomableImage c) => {
  'src': c.src,
  'alt': c.alt,
  'caption': c.caption,
};
Map<String, dynamic> _prefix7GithubButton(prefix7.GithubButton c) => {
  'repo': c.repo,
};
