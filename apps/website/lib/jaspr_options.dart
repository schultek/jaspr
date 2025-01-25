// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:website/components/code_window.dart' as prefix0;
import 'package:website/components/feature_box.dart' as prefix1;
import 'package:website/components/github_button.dart' as prefix2;
import 'package:website/components/icon.dart' as prefix3;
import 'package:website/components/install_command.dart' as prefix4;
import 'package:website/components/link_button.dart' as prefix5;
import 'package:website/components/link_card.dart' as prefix6;
import 'package:website/components/logo.dart' as prefix7;
import 'package:website/components/meet_jaspr_button.dart' as prefix8;
import 'package:website/components/modes_animation.dart' as prefix9;
import 'package:website/components/sponsors_list.dart' as prefix10;
import 'package:website/components/testimonial_card.dart' as prefix11;
import 'package:website/components/theme_toggle.dart' as prefix12;
import 'package:website/constants/theme.dart' as prefix13;
import 'package:website/highlight/code_block.dart' as prefix14;
import 'package:website/pages/home/sections/0_header.dart' as prefix15;
import 'package:website/pages/home/sections/1_hero.dart' as prefix16;
import 'package:website/pages/home/sections/2_meet.dart' as prefix17;
import 'package:website/pages/home/sections/3_devexp.dart' as prefix18;
import 'package:website/pages/home/sections/4_features.dart' as prefix19;
import 'package:website/pages/home/sections/5_testimonials.dart' as prefix20;
import 'package:website/pages/home/sections/6_community.dart' as prefix21;
import 'package:website/pages/home/sections/7_footer.dart' as prefix22;
import 'package:website/app.dart' as prefix23;

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
    prefix2.GithubButton: ClientTarget<prefix2.GithubButton>('components/github_button'),
    prefix4.InstallCommand: ClientTarget<prefix4.InstallCommand>('components/install_command'),
    prefix8.MeetJasprButton: ClientTarget<prefix8.MeetJasprButton>('components/meet_jaspr_button'),
    prefix9.ModesAnimation: ClientTarget<prefix9.ModesAnimation>('components/modes_animation'),
    prefix10.SponsorsList: ClientTarget<prefix10.SponsorsList>('components/sponsors_list'),
    prefix12.ThemeToggle: ClientTarget<prefix12.ThemeToggle>('components/theme_toggle'),
  },
  styles: () => [
    ...prefix0.CodeWindow.styles,
    ...prefix1.FeatureBox.styles,
    ...prefix2.GithubButtonState.styles,
    ...prefix3.Icon.styles,
    ...prefix4.InstallCommandState.styles,
    ...prefix5.LinkButton.styles,
    ...prefix6.LinkCard.styles,
    ...prefix7.Logo.styles,
    ...prefix8.MeetJasprButtonState.styles,
    ...prefix10.SponsorsListState.styles,
    ...prefix11.TestimonialCard.styles,
    ...prefix12.ThemeToggleState.styles,
    ...prefix13.root,
    ...prefix14.CodeBlock.styles,
    ...prefix15.Header.styles,
    ...prefix16.Hero.styles,
    ...prefix17.Meet.styles,
    ...prefix18.DevExp.styles,
    ...prefix19.Features.styles,
    ...prefix20.Testimonials.styles,
    ...prefix21.Community.styles,
    ...prefix22.Footer.styles,
    ...prefix23.App.styles,
  ],
);
