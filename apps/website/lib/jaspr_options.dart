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
import 'package:website/components/menu_button.dart' as prefix9;
import 'package:website/components/theme_toggle.dart' as prefix10;
import 'package:website/constants/theme.dart' as prefix11;
import 'package:website/pages/home/0_hero/components/install_command.dart' as prefix12;
import 'package:website/pages/home/0_hero/components/meet_jaspr_button.dart' as prefix13;
import 'package:website/pages/home/0_hero/components/overlay.dart' as prefix14;
import 'package:website/pages/home/0_hero/hero.dart' as prefix15;
import 'package:website/pages/home/1_meet/components/modes_animation.dart' as prefix16;
import 'package:website/pages/home/1_meet/meet.dart' as prefix17;
import 'package:website/pages/home/2_devexp/components/animated_console.dart' as prefix18;
import 'package:website/pages/home/2_devexp/components/feature_box.dart' as prefix19;
import 'package:website/pages/home/2_devexp/devexp.dart' as prefix20;
import 'package:website/pages/home/3_features/components/link_card.dart' as prefix21;
import 'package:website/pages/home/3_features/features.dart' as prefix22;
import 'package:website/pages/home/4_testimonials/components/testimonial_card.dart' as prefix23;
import 'package:website/pages/home/4_testimonials/testimonials.dart' as prefix24;
import 'package:website/pages/home/5_community/components/sponsors_list.dart' as prefix25;
import 'package:website/pages/home/5_community/community.dart' as prefix26;
import 'package:website/app.dart' as prefix27;

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
    prefix5.Header: ClientTarget<prefix5.Header>('components/header'),
    prefix12.InstallCommand: ClientTarget<prefix12.InstallCommand>('pages/home/0_hero/components/install_command'),
    prefix13.MeetJasprButton: ClientTarget<prefix13.MeetJasprButton>('pages/home/0_hero/components/meet_jaspr_button'),
    prefix16.ModesAnimation: ClientTarget<prefix16.ModesAnimation>('pages/home/1_meet/components/modes_animation'),
    prefix25.SponsorsList: ClientTarget<prefix25.SponsorsList>('pages/home/5_community/components/sponsors_list'),
  },
  styles: () => [
    ...prefix0.CodeBlock.styles,
    ...prefix1.CodeWindow.styles,
    ...prefix2.Footer.styles,
    ...prefix3.GithubButtonState.styles,
    ...prefix4.GradientBorder.styles,
    ...prefix5.HeaderState.styles,
    ...prefix6.Icon.styles,
    ...prefix7.LinkButton.styles,
    ...prefix8.Logo.styles,
    ...prefix9.MenuButton.styles,
    ...prefix10.ThemeToggleState.styles,
    ...prefix11.root,
    ...prefix12.InstallCommandState.styles,
    ...prefix13.MeetJasprButtonState.styles,
    ...prefix14.OverlayState.styles,
    ...prefix15.Hero.styles,
    ...prefix17.Meet.styles,
    ...prefix18.AnimatedConsoleState.styles,
    ...prefix19.FeatureBox.styles,
    ...prefix20.DevExp.styles,
    ...prefix21.LinkCard.styles,
    ...prefix22.Features.styles,
    ...prefix23.TestimonialCard.styles,
    ...prefix24.Testimonials.styles,
    ...prefix25.SponsorsListState.styles,
    ...prefix26.Community.styles,
    ...prefix27.App.styles,
  ],
);
