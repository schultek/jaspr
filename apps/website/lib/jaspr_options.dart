// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:website/components/code_window/code_block.dart' as prefix0;
import 'package:website/components/code_window/code_window.dart' as prefix1;
import 'package:website/components/footer.dart' as prefix2;
import 'package:website/components/github_button.dart' as prefix3;
import 'package:website/components/gradient_border.dart' as prefix4;
import 'package:website/components/header.dart' as prefix5;
import 'package:website/components/icon.dart' as prefix6;
import 'package:website/components/link_button.dart' as prefix7;
import 'package:website/components/logo.dart' as prefix8;
import 'package:website/components/theme_toggle.dart' as prefix9;
import 'package:website/constants/theme.dart' as prefix10;
import 'package:website/pages/home/0_hero/components/install_command.dart' as prefix11;
import 'package:website/pages/home/0_hero/components/meet_jaspr_button.dart' as prefix12;
import 'package:website/pages/home/0_hero/components/overlay.dart' as prefix13;
import 'package:website/pages/home/0_hero/hero.dart' as prefix14;
import 'package:website/pages/home/1_meet/components/modes_animation.dart' as prefix15;
import 'package:website/pages/home/1_meet/meet.dart' as prefix16;
import 'package:website/pages/home/2_devexp/components/animated_console.dart' as prefix17;
import 'package:website/pages/home/2_devexp/components/feature_box.dart' as prefix18;
import 'package:website/pages/home/2_devexp/devexp.dart' as prefix19;
import 'package:website/pages/home/3_features/components/link_card.dart' as prefix20;
import 'package:website/pages/home/3_features/features.dart' as prefix21;
import 'package:website/pages/home/4_testimonials/components/testimonial_card.dart' as prefix22;
import 'package:website/pages/home/4_testimonials/testimonials.dart' as prefix23;
import 'package:website/pages/home/5_community/components/sponsors_list.dart' as prefix24;
import 'package:website/pages/home/5_community/community.dart' as prefix25;
import 'package:website/app.dart' as prefix26;

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
    prefix3.GithubButton: ClientTarget<prefix3.GithubButton>('components/github_button'),
    prefix9.ThemeToggle: ClientTarget<prefix9.ThemeToggle>('components/theme_toggle'),
    prefix11.InstallCommand: ClientTarget<prefix11.InstallCommand>('pages/home/0_hero/components/install_command'),
    prefix12.MeetJasprButton: ClientTarget<prefix12.MeetJasprButton>('pages/home/0_hero/components/meet_jaspr_button'),
    prefix15.ModesAnimation: ClientTarget<prefix15.ModesAnimation>('pages/home/1_meet/components/modes_animation'),
    prefix24.SponsorsList: ClientTarget<prefix24.SponsorsList>('pages/home/5_community/components/sponsors_list'),
  },
  styles: () => [
    ...prefix0.CodeBlock.styles,
    ...prefix1.CodeWindow.styles,
    ...prefix2.Footer.styles,
    ...prefix3.GithubButtonState.styles,
    ...prefix4.GradientBorder.styles,
    ...prefix5.Header.styles,
    ...prefix6.Icon.styles,
    ...prefix7.LinkButton.styles,
    ...prefix8.Logo.styles,
    ...prefix9.ThemeToggleState.styles,
    ...prefix10.root,
    ...prefix11.InstallCommandState.styles,
    ...prefix12.MeetJasprButtonState.styles,
    ...prefix13.OverlayState.styles,
    ...prefix14.Hero.styles,
    ...prefix16.Meet.styles,
    ...prefix17.AnimatedConsoleState.styles,
    ...prefix18.FeatureBox.styles,
    ...prefix19.DevExp.styles,
    ...prefix20.LinkCard.styles,
    ...prefix21.Features.styles,
    ...prefix22.TestimonialCard.styles,
    ...prefix23.Testimonials.styles,
    ...prefix24.SponsorsListState.styles,
    ...prefix25.Community.styles,
    ...prefix26.App.styles,
  ],
);
