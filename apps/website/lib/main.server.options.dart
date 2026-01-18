// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:website/components/code_window/code_block.dart' as _code_block;
import 'package:website/components/code_window/code_window.dart'
    as _code_window;
import 'package:website/components/layout/footer.dart' as _footer;
import 'package:website/components/layout/header.dart' as _header;
import 'package:website/components/banner.dart' as _banner;
import 'package:website/components/github_button.dart' as _github_button;
import 'package:website/components/gradient_border.dart' as _gradient_border;
import 'package:website/components/icon.dart' as _icon;
import 'package:website/components/link_button.dart' as _link_button;
import 'package:website/components/logo.dart' as _logo;
import 'package:website/components/menu_button.dart' as _menu_button;
import 'package:website/components/particles.dart' as _particles;
import 'package:website/components/theme_toggle.dart' as _theme_toggle;
import 'package:website/constants/theme.dart' as _theme;
import 'package:website/layouts/home_layout.dart' as _home_layout;
import 'package:website/layouts/imprint_layout.dart' as _imprint_layout;
import 'package:website/pages/home/0_hero/components/hero_pill.dart'
    as _hero_pill;
import 'package:website/pages/home/0_hero/components/install_command.dart'
    as _install_command;
import 'package:website/pages/home/0_hero/components/meet_jaspr_button.dart'
    as _meet_jaspr_button;
import 'package:website/pages/home/0_hero/components/overlay.dart' as _overlay;
import 'package:website/pages/home/0_hero/hero.dart' as _hero;
import 'package:website/pages/home/1_meet/components/modes_animation.dart'
    as _modes_animation;
import 'package:website/pages/home/1_meet/meet.dart' as _meet;
import 'package:website/pages/home/2_devex/components/counter_button.dart'
    as _counter_button;
import 'package:website/pages/home/2_devex/components/devex_box.dart'
    as _devex_box;
import 'package:website/pages/home/2_devex/items/0_develop.dart' as _0_develop;
import 'package:website/pages/home/2_devex/items/1_run.dart' as _1_run;
import 'package:website/pages/home/2_devex/items/3_analyze.dart' as _3_analyze;
import 'package:website/pages/home/2_devex/devex.dart' as _devex;
import 'package:website/pages/home/3_features/components/link_card.dart'
    as _link_card;
import 'package:website/pages/home/3_features/features.dart' as _features;
import 'package:website/pages/home/4_testimonials/components/testimonial_card.dart'
    as _testimonial_card;
import 'package:website/pages/home/4_testimonials/testimonials.dart'
    as _testimonials;
import 'package:website/pages/home/5_community/components/sponsors_list.dart'
    as _sponsors_list;
import 'package:website/pages/home/5_community/community.dart' as _community;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
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
    _header.Header: ClientTarget<_header.Header>(
      'header',
      params: __headerHeader,
    ),
    _install_command.InstallCommand:
        ClientTarget<_install_command.InstallCommand>('install_command'),
    _meet_jaspr_button.MeetJasprButton:
        ClientTarget<_meet_jaspr_button.MeetJasprButton>('meet_jaspr_button'),
    _modes_animation.ModesAnimation:
        ClientTarget<_modes_animation.ModesAnimation>('modes_animation'),
    _counter_button.CounterButton: ClientTarget<_counter_button.CounterButton>(
      'counter_button',
    ),
    _sponsors_list.SponsorsList: ClientTarget<_sponsors_list.SponsorsList>(
      'sponsors_list',
    ),
  },
  styles: () => [
    ..._code_block.CodeBlock.styles,
    ..._code_window.CodeWindow.styles,
    ..._footer.Footer.styles,
    ..._header.HeaderState.styles,
    ..._banner.Banner.styles,
    ..._github_button.GitHubButtonState.styles,
    ..._gradient_border.GradientBorder.styles,
    ..._icon.Icon.styles,
    ..._link_button.LinkButton.styles,
    ..._logo.Logo.styles,
    ..._menu_button.MenuButton.styles,
    ..._particles.Particles.styles,
    ..._theme_toggle.ThemeToggleState.styles,
    ..._theme.root,
    ..._home_layout.HomeLayout.styles,
    ..._imprint_layout.ImprintLayout.styles,
    ..._hero_pill.HeroPill.styles,
    ..._install_command.InstallCommandState.styles,
    ..._meet_jaspr_button.MeetJasprButtonState.styles,
    ..._overlay.OverlayState.styles,
    ..._hero.Hero.styles,
    ..._meet.Meet.styles,
    ..._counter_button.CounterButtonState.styles,
    ..._devex_box.DevexBox.styles,
    ..._0_develop.Develop.styles,
    ..._1_run.Run.styles,
    ..._3_analyze.Analyze.styles,
    ..._devex.DevExp.styles,
    ..._link_card.LinkCard.styles,
    ..._features.Features.styles,
    ..._testimonial_card.TestimonialCard.styles,
    ..._testimonials.Testimonials.styles,
    ..._sponsors_list.SponsorsListState.styles,
    ..._community.Community.styles,
  ],
);

Map<String, Object?> __headerHeader(_header.Header c) => {
  'showHome': c.showHome,
};
