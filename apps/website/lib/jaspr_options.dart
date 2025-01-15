// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:website/components/github_button.dart' as prefix0;
import 'package:website/components/header.dart' as prefix1;
import 'package:website/components/icon.dart' as prefix2;
import 'package:website/components/install_command.dart' as prefix3;
import 'package:website/components/link_button.dart' as prefix4;
import 'package:website/components/theme_toggle.dart' as prefix5;
import 'package:website/constants/theme.dart' as prefix6;
import 'package:website/pages/home/sections/0_hero.dart' as prefix7;
import 'package:website/pages/home/sections/1_meet.dart' as prefix8;
import 'package:website/app.dart' as prefix9;

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
final defaultJasprOptions = JasprOptions(
  clients: {
    prefix0.GithubButton: ClientTarget<prefix0.GithubButton>('components/github_button'),
    prefix3.InstallCommand: ClientTarget<prefix3.InstallCommand>('components/install_command'),
    prefix5.ThemeToggle: ClientTarget<prefix5.ThemeToggle>('components/theme_toggle'),
  },
  styles: () => [
    ...prefix0.GithubButtonState.styles,
    ...prefix1.Header.styles,
    ...prefix2.Icon.styles,
    ...prefix3.InstallCommandState.styles,
    ...prefix4.LinkButton.styles,
    ...prefix5.ThemeToggleState.styles,
    ...prefix6.root,
    ...prefix7.Hero.styles,
    ...prefix8.Meet.styles,
    ...prefix9.App.styles,
  ],
);
