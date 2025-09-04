// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:website/components/code_window/code_block.dart' as prefix0;
import 'package:website/components/code_window/code_window.dart' as prefix1;
import 'package:website/components/banner.dart' as prefix2;
import 'package:website/components/github_button.dart' as prefix3;
import 'package:website/components/gradient_border.dart' as prefix4;
import 'package:website/components/icon.dart' as prefix5;
import 'package:website/components/link_button.dart' as prefix6;
import 'package:website/components/logo.dart' as prefix7;
import 'package:website/components/markdown_page.dart' as prefix8;
import 'package:website/components/menu_button.dart' as prefix9;
import 'package:website/components/particles.dart' as prefix10;
import 'package:website/components/theme_toggle.dart' as prefix11;
import 'package:website/constants/theme.dart' as prefix12;
import 'package:website/layout/footer.dart' as prefix13;
import 'package:website/layout/header.dart' as prefix14;
import 'package:website/pages/home/0_hero/components/hero_pill.dart' as prefix15;
import 'package:website/pages/home/0_hero/components/install_command.dart' as prefix16;
import 'package:website/pages/home/0_hero/components/meet_jaspr_button.dart' as prefix17;
import 'package:website/pages/home/0_hero/components/overlay.dart' as prefix18;
import 'package:website/pages/home/0_hero/hero.dart' as prefix19;
import 'package:website/pages/home/1_meet/components/modes_animation.dart' as prefix20;
import 'package:website/pages/home/1_meet/meet.dart' as prefix21;
import 'package:website/pages/home/2_devex/components/counter_button.dart' as prefix22;
import 'package:website/pages/home/2_devex/components/devex_box.dart' as prefix23;
import 'package:website/pages/home/2_devex/items/0_develop.dart' as prefix24;
import 'package:website/pages/home/2_devex/items/1_run.dart' as prefix25;
import 'package:website/pages/home/2_devex/items/3_analyze.dart' as prefix26;
import 'package:website/pages/home/2_devex/devex.dart' as prefix27;
import 'package:website/pages/home/3_features/components/link_card.dart' as prefix28;
import 'package:website/pages/home/3_features/features.dart' as prefix29;
import 'package:website/pages/home/4_testimonials/components/testimonial_card.dart' as prefix30;
import 'package:website/pages/home/4_testimonials/testimonials.dart' as prefix31;
import 'package:website/pages/home/5_community/components/sponsors_list.dart' as prefix32;
import 'package:website/pages/home/5_community/community.dart' as prefix33;
import 'package:website/app.dart' as prefix34;

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
        prefix14.Header: ClientTarget<prefix14.Header>(
          'layout/header',
          params: _prefix14Header,
        ),
        prefix16.InstallCommand: ClientTarget<prefix16.InstallCommand>(
          'pages/home/0_hero/components/install_command',
        ),
        prefix17.MeetJasprButton: ClientTarget<prefix17.MeetJasprButton>(
          'pages/home/0_hero/components/meet_jaspr_button',
        ),
        prefix20.ModesAnimation: ClientTarget<prefix20.ModesAnimation>(
          'pages/home/1_meet/components/modes_animation',
        ),
        prefix22.CounterButton: ClientTarget<prefix22.CounterButton>(
          'pages/home/2_devex/components/counter_button',
        ),
        prefix32.SponsorsList: ClientTarget<prefix32.SponsorsList>(
          'pages/home/5_community/components/sponsors_list',
        ),
      },
      styles: () => [
        ...prefix0.CodeBlock.styles,
        ...prefix1.CodeWindow.styles,
        ...prefix2.Banner.styles,
        ...prefix3.GitHubButtonState.styles,
        ...prefix4.GradientBorder.styles,
        ...prefix5.Icon.styles,
        ...prefix6.LinkButton.styles,
        ...prefix7.Logo.styles,
        ...prefix8.MarkdownPage.styles,
        ...prefix9.MenuButton.styles,
        ...prefix10.Particles.styles,
        ...prefix11.ThemeToggleState.styles,
        ...prefix12.root,
        ...prefix13.Footer.styles,
        ...prefix14.HeaderState.styles,
        ...prefix15.HeroPill.styles,
        ...prefix16.InstallCommandState.styles,
        ...prefix17.MeetJasprButtonState.styles,
        ...prefix18.OverlayState.styles,
        ...prefix19.Hero.styles,
        ...prefix21.Meet.styles,
        ...prefix22.CounterButtonState.styles,
        ...prefix23.DevexBox.styles,
        ...prefix24.Develop.styles,
        ...prefix25.Run.styles,
        ...prefix26.Analyze.styles,
        ...prefix27.DevExp.styles,
        ...prefix28.LinkCard.styles,
        ...prefix29.Features.styles,
        ...prefix30.TestimonialCard.styles,
        ...prefix31.Testimonials.styles,
        ...prefix32.SponsorsListState.styles,
        ...prefix33.Community.styles,
        ...prefix34.App.styles,
      ],
    );

Map<String, dynamic> _prefix14Header(prefix14.Header c) => {
      'showHome': c.showHome,
    };
