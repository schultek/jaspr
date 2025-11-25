// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core_web/firebase_core_web.dart' as $firebase_core_web;
import 'package:flutter_embedding_demo/components/app.dart' deferred as $app;

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
  initialize: () {
    final Registrar registrar = webPluginRegistrar;
    $firebase_core_web.FirebaseCoreWeb.registerWith(registrar);
    registrar.registerMessageHandler();
  },
  clients: {'app': ClientLoader((p) => $app.App(), loader: $app.loadLibrary)},
);
