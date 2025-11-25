// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:website/layout/header.dart' deferred as $header;
import 'package:website/pages/home/0_hero/components/install_command.dart'
    deferred as $install_command;
import 'package:website/pages/home/0_hero/components/meet_jaspr_button.dart'
    deferred as $meet_jaspr_button;
import 'package:website/pages/home/1_meet/components/modes_animation.dart'
    deferred as $modes_animation;
import 'package:website/pages/home/2_devex/components/counter_button.dart'
    deferred as $counter_button;
import 'package:website/pages/home/5_community/components/sponsors_list.dart'
    deferred as $sponsors_list;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.g.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(
  clients: {
    'header': ClientLoader(
      (p) => $header.Header(showHome: p['showHome']),
      loader: $header.loadLibrary,
    ),
    'install_command': ClientLoader(
      (p) => $install_command.InstallCommand(),
      loader: $install_command.loadLibrary,
    ),
    'meet_jaspr_button': ClientLoader(
      (p) => $meet_jaspr_button.MeetJasprButton(),
      loader: $meet_jaspr_button.loadLibrary,
    ),
    'modes_animation': ClientLoader(
      (p) => $modes_animation.ModesAnimation(),
      loader: $modes_animation.loadLibrary,
    ),
    'counter_button': ClientLoader(
      (p) => $counter_button.CounterButton(),
      loader: $counter_button.loadLibrary,
    ),
    'sponsors_list': ClientLoader(
      (p) => $sponsors_list.SponsorsList(),
      loader: $sponsors_list.loadLibrary,
    ),
  },
);
