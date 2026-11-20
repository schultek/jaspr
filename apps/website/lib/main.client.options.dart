// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:website/components/layout/header.dart' deferred as _header;
import 'package:website/pages/home/0_hero/components/install_command.dart'
    deferred as _install_command;
import 'package:website/pages/home/0_hero/components/meet_jaspr_button.dart'
    deferred as _meet_jaspr_button;
import 'package:website/pages/home/1_meet/components/modes_animation.dart'
    deferred as _modes_animation;
import 'package:website/pages/home/2_devex/components/counter_button.dart'
    deferred as _counter_button;
import 'package:website/pages/home/5_community/components/sponsors_list.dart'
    deferred as _sponsors_list;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(clients: _$clients);

// A top-level function, so hot reload picks up added or removed clients.
Map<String, ClientLoader> _$clients() => {
  'header': ClientLoader(
    (p) => _header.Header(showHome: p.get<bool>('showHome')),
    loader: _header.loadLibrary,
    libraryId: kDebugMode
        ? 'package:website/components/layout/header.dart'
        : null,
  ),
  'install_command': ClientLoader(
    (p) => _install_command.InstallCommand(),
    loader: _install_command.loadLibrary,
    libraryId: kDebugMode
        ? 'package:website/pages/home/0_hero/components/install_command.dart'
        : null,
  ),
  'meet_jaspr_button': ClientLoader(
    (p) => _meet_jaspr_button.MeetJasprButton(),
    loader: _meet_jaspr_button.loadLibrary,
    libraryId: kDebugMode
        ? 'package:website/pages/home/0_hero/components/meet_jaspr_button.dart'
        : null,
  ),
  'modes_animation': ClientLoader(
    (p) => _modes_animation.ModesAnimation(),
    loader: _modes_animation.loadLibrary,
    libraryId: kDebugMode
        ? 'package:website/pages/home/1_meet/components/modes_animation.dart'
        : null,
  ),
  'counter_button': ClientLoader(
    (p) => _counter_button.CounterButton(),
    loader: _counter_button.loadLibrary,
    libraryId: kDebugMode
        ? 'package:website/pages/home/2_devex/components/counter_button.dart'
        : null,
  ),
  'sponsors_list': ClientLoader(
    (p) => _sponsors_list.SponsorsList(),
    loader: _sponsors_list.loadLibrary,
    libraryId: kDebugMode
        ? 'package:website/pages/home/5_community/components/sponsors_list.dart'
        : null,
  ),
};
