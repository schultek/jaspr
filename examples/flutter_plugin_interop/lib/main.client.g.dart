// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart'
    as $cloud_firestore_web;
import 'package:firebase_auth_web/firebase_auth_web.dart' as $firebase_auth_web;
import 'package:firebase_core_web/firebase_core_web.dart' as $firebase_core_web;
import 'package:flutter_plugin_interop/components/app.dart' deferred as $app;
import 'package:shared_preferences_web/shared_preferences_web.dart'
    as $shared_preferences_web;

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
    $shared_preferences_web.SharedPreferencesPlugin.registerWith(registrar);
    $firebase_core_web.FirebaseCoreWeb.registerWith(registrar);
    $firebase_auth_web.FirebaseAuthWeb.registerWith(registrar);
    $cloud_firestore_web.FirebaseFirestoreWeb.registerWith(registrar);
    registrar.registerMessageHandler();
  },
  clients: {'app': ClientLoader((p) => $app.App(), loader: $app.loadLibrary)},
);
