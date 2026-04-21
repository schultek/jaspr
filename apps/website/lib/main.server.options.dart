// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:website/components/layout/header.dart' as _header;
import 'package:website/pages/home/0_hero/components/install_command.dart'
    as _install_command;
import 'package:website/pages/home/0_hero/components/meet_jaspr_button.dart'
    as _meet_jaspr_button;
import 'package:website/pages/home/1_meet/components/modes_animation.dart'
    as _modes_animation;
import 'package:website/pages/home/2_devex/components/counter_button.dart'
    as _counter_button;
import 'package:website/pages/home/5_community/components/sponsors_list.dart'
    as _sponsors_list;

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
  stylesId: 'main.css',
);

Map<String, Object?> __headerHeader(_header.Header c) => {
  'showHome': c.showHome,
};
