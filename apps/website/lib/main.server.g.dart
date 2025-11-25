// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:website/components/code_window/code_block.dart' as $code_block;
import 'package:website/components/code_window/code_window.dart'
    as $code_window;
import 'package:website/components/banner.dart' as $banner;
import 'package:website/components/github_button.dart' as $github_button;
import 'package:website/components/gradient_border.dart' as $gradient_border;
import 'package:website/components/icon.dart' as $icon;
import 'package:website/components/link_button.dart' as $link_button;
import 'package:website/components/logo.dart' as $logo;
import 'package:website/components/markdown_page.dart' as $markdown_page;
import 'package:website/components/menu_button.dart' as $menu_button;
import 'package:website/components/particles.dart' as $particles;
import 'package:website/components/theme_toggle.dart' as $theme_toggle;
import 'package:website/constants/theme.dart' as $theme;
import 'package:website/layout/footer.dart' as $footer;
import 'package:website/layout/header.dart' as $header;
import 'package:website/pages/home/0_hero/components/hero_pill.dart'
    as $hero_pill;
import 'package:website/pages/home/0_hero/components/install_command.dart'
    as $install_command;
import 'package:website/pages/home/0_hero/components/meet_jaspr_button.dart'
    as $meet_jaspr_button;
import 'package:website/pages/home/0_hero/components/overlay.dart' as $overlay;
import 'package:website/pages/home/0_hero/hero.dart' as $hero;
import 'package:website/pages/home/1_meet/components/modes_animation.dart'
    as $modes_animation;
import 'package:website/pages/home/1_meet/meet.dart' as $meet;
import 'package:website/pages/home/2_devex/components/counter_button.dart'
    as $counter_button;
import 'package:website/pages/home/2_devex/components/devex_box.dart'
    as $devex_box;
import 'package:website/pages/home/2_devex/items/0_develop.dart' as $0_develop;
import 'package:website/pages/home/2_devex/items/1_run.dart' as $1_run;
import 'package:website/pages/home/2_devex/items/3_analyze.dart' as $3_analyze;
import 'package:website/pages/home/2_devex/devex.dart' as $devex;
import 'package:website/pages/home/3_features/components/link_card.dart'
    as $link_card;
import 'package:website/pages/home/3_features/features.dart' as $features;
import 'package:website/pages/home/4_testimonials/components/testimonial_card.dart'
    as $testimonial_card;
import 'package:website/pages/home/4_testimonials/testimonials.dart'
    as $testimonials;
import 'package:website/pages/home/5_community/components/sponsors_list.dart'
    as $sponsors_list;
import 'package:website/pages/home/5_community/community.dart' as $community;
import 'package:website/app.dart' as $app;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.g.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {
    $header.Header: ClientTarget<$header.Header>(
      'header',
      params: _$headerHeader,
    ),
    $install_command.InstallCommand:
        ClientTarget<$install_command.InstallCommand>('install_command'),
    $meet_jaspr_button.MeetJasprButton:
        ClientTarget<$meet_jaspr_button.MeetJasprButton>('meet_jaspr_button'),
    $modes_animation.ModesAnimation:
        ClientTarget<$modes_animation.ModesAnimation>('modes_animation'),
    $counter_button.CounterButton: ClientTarget<$counter_button.CounterButton>(
      'counter_button',
    ),
    $sponsors_list.SponsorsList: ClientTarget<$sponsors_list.SponsorsList>(
      'sponsors_list',
    ),
  },
  styles: () => [
    ...$code_block.CodeBlock.styles,
    ...$code_window.CodeWindow.styles,
    ...$banner.Banner.styles,
    ...$github_button.GitHubButtonState.styles,
    ...$gradient_border.GradientBorder.styles,
    ...$icon.Icon.styles,
    ...$link_button.LinkButton.styles,
    ...$logo.Logo.styles,
    ...$markdown_page.MarkdownPage.styles,
    ...$menu_button.MenuButton.styles,
    ...$particles.Particles.styles,
    ...$theme_toggle.ThemeToggleState.styles,
    ...$theme.root,
    ...$footer.Footer.styles,
    ...$header.HeaderState.styles,
    ...$hero_pill.HeroPill.styles,
    ...$install_command.InstallCommandState.styles,
    ...$meet_jaspr_button.MeetJasprButtonState.styles,
    ...$overlay.OverlayState.styles,
    ...$hero.Hero.styles,
    ...$meet.Meet.styles,
    ...$counter_button.CounterButtonState.styles,
    ...$devex_box.DevexBox.styles,
    ...$0_develop.Develop.styles,
    ...$1_run.Run.styles,
    ...$3_analyze.Analyze.styles,
    ...$devex.DevExp.styles,
    ...$link_card.LinkCard.styles,
    ...$features.Features.styles,
    ...$testimonial_card.TestimonialCard.styles,
    ...$testimonials.Testimonials.styles,
    ...$sponsors_list.SponsorsListState.styles,
    ...$community.Community.styles,
    ...$app.App.styles,
  ],
);

Map<String, Object?> _$headerHeader($header.Header c) => {
  'showHome': c.showHome,
};
