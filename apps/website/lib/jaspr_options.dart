// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:website/components/code_window/code_block.dart' as prefix0;
import 'package:website/components/code_window/code_window.dart' as prefix1;
import 'package:website/components/github_button.dart' as prefix2;
import 'package:website/components/gradient_border.dart' as prefix3;
import 'package:website/components/icon.dart' as prefix4;
import 'package:website/components/link_button.dart' as prefix5;
import 'package:website/components/logo.dart' as prefix6;
import 'package:website/components/markdown_page.dart' as prefix7;
import 'package:website/components/menu_button.dart' as prefix8;
import 'package:website/components/particles.dart' as prefix9;
import 'package:website/components/theme_toggle.dart' as prefix10;
import 'package:website/constants/theme.dart' as prefix11;
import 'package:website/layout/footer.dart' as prefix12;
import 'package:website/layout/header.dart' as prefix13;
import 'package:website/pages/home/0_hero/components/install_command.dart' as prefix14;
import 'package:website/pages/home/0_hero/components/meet_jaspr_button.dart' as prefix15;
import 'package:website/pages/home/0_hero/components/overlay.dart' as prefix16;
import 'package:website/pages/home/0_hero/hero.dart' as prefix17;
import 'package:website/pages/home/1_meet/components/modes_animation.dart' as prefix18;
import 'package:website/pages/home/1_meet/meet.dart' as prefix19;
import 'package:website/pages/home/2_devex/components/counter_button.dart' as prefix20;
import 'package:website/pages/home/2_devex/components/devex_box.dart' as prefix21;
import 'package:website/pages/home/2_devex/items/0_develop.dart' as prefix22;
import 'package:website/pages/home/2_devex/items/1_run.dart' as prefix23;
import 'package:website/pages/home/2_devex/items/3_analyze.dart' as prefix24;
import 'package:website/pages/home/2_devex/devex.dart' as prefix25;
import 'package:website/pages/home/3_features/components/link_card.dart' as prefix26;
import 'package:website/pages/home/3_features/features.dart' as prefix27;
import 'package:website/pages/home/4_testimonials/components/testimonial_card.dart' as prefix28;
import 'package:website/pages/home/4_testimonials/testimonials.dart' as prefix29;
import 'package:website/pages/home/5_community/components/sponsors_list.dart' as prefix30;
import 'package:website/pages/home/5_community/community.dart' as prefix31;
import 'package:website/app.dart' as prefix32;

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
        prefix13.Header: ClientTarget<prefix13.Header>(
          'layout/header',
          params: _prefix13Header,
        ),
        prefix14.InstallCommand: ClientTarget<prefix14.InstallCommand>(
          'pages/home/0_hero/components/install_command',
        ),
        prefix15.MeetJasprButton: ClientTarget<prefix15.MeetJasprButton>(
          'pages/home/0_hero/components/meet_jaspr_button',
        ),
        prefix18.ModesAnimation: ClientTarget<prefix18.ModesAnimation>(
          'pages/home/1_meet/components/modes_animation',
        ),
        prefix20.CounterButton: ClientTarget<prefix20.CounterButton>(
          'pages/home/2_devex/components/counter_button',
        ),
        prefix30.SponsorsList: ClientTarget<prefix30.SponsorsList>(
          'pages/home/5_community/components/sponsors_list',
        ),
      },
      styles: () => [
        ...prefix0.CodeBlock.styles,
        ...prefix1.CodeWindow.styles,
        ...prefix2.GithubButtonState.styles,
        ...prefix3.GradientBorder.styles,
        ...prefix4.Icon.styles,
        ...prefix5.LinkButton.styles,
        ...prefix6.Logo.styles,
        ...prefix7.MarkdownPage.styles,
        ...prefix8.MenuButton.styles,
        ...prefix9.Particles.styles,
        ...prefix10.ThemeToggleState.styles,
        ...prefix11.root,
        ...prefix12.Footer.styles,
        ...prefix13.HeaderState.styles,
        ...prefix14.InstallCommandState.styles,
        ...prefix15.MeetJasprButtonState.styles,
        ...prefix16.OverlayState.styles,
        ...prefix17.Hero.styles,
        ...prefix19.Meet.styles,
        ...prefix20.CounterButtonState.styles,
        ...prefix21.DevexBox.styles,
        ...prefix22.Develop.styles,
        ...prefix23.Run.styles,
        ...prefix24.Analyze.styles,
        ...prefix25.DevExp.styles,
        ...prefix26.LinkCard.styles,
        ...prefix27.Features.styles,
        ...prefix28.TestimonialCard.styles,
        ...prefix29.Testimonials.styles,
        ...prefix30.SponsorsListState.styles,
        ...prefix31.Community.styles,
        ...prefix32.App.styles,
      ],
    );

Map<String, dynamic> _prefix13Header(prefix13.Header c) => {
      'showHome': c.showHome,
    };
