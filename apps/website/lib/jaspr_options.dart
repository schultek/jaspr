// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:website/components/github_button.dart' as prefix0;
import 'package:website/components/header.dart' as prefix1;
import 'package:website/components/icon.dart' as prefix2;
import 'package:website/components/install_command.dart' as prefix3;
import 'package:website/components/link_button.dart' as prefix4;
import 'package:website/components/modes_animation.dart' as prefix5;
import 'package:website/components/theme_toggle.dart' as prefix6;
import 'package:website/constants/theme.dart' as prefix7;
import 'package:website/pages/home/sections/0_hero.dart' as prefix8;
import 'package:website/pages/home/sections/1_meet.dart' as prefix9;
import 'package:website/pages/home/sections/2_devexp.dart' as prefix10;
import 'package:website/pages/home/sections/3_features.dart' as prefix11;
import 'package:website/app.dart' as prefix12;

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
    prefix5.ModesAnimation: ClientTarget<prefix5.ModesAnimation>('components/modes_animation'),
    prefix6.ThemeToggle: ClientTarget<prefix6.ThemeToggle>('components/theme_toggle'),
  },
  styles: () => [
    ...prefix0.GithubButtonState.styles,
    ...prefix1.Header.styles,
    ...prefix2.Icon.styles,
    ...prefix3.InstallCommandState.styles,
    ...prefix4.LinkButton.styles,
    ...prefix6.ThemeToggleState.styles,
    ...prefix7.root,
    ...prefix8.Hero.styles,
    ...prefix9.Meet.styles,
    ...prefix10.DevExp.styles,
    ...prefix11.Features.styles,
    ...prefix12.App.styles,
  ],
);
