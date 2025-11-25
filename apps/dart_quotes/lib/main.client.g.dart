// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart'
    as $cloud_firestore_web;
import 'package:dart_quotes/components/quote_like_button.dart'
    deferred as $quote_like_button;
import 'package:firebase_auth_web/firebase_auth_web.dart' as $firebase_auth_web;
import 'package:firebase_core_web/firebase_core_web.dart' as $firebase_core_web;

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
    $firebase_auth_web.FirebaseAuthWeb.registerWith(registrar);
    $cloud_firestore_web.FirebaseFirestoreWeb.registerWith(registrar);
    registrar.registerMessageHandler();
  },
  clients: {
    'quote_like_button': ClientLoader(
      (p) => $quote_like_button.QuoteLikeButton(
        id: p['id'],
        initialCount: p['initialCount'],
      ),
      loader: $quote_like_button.loadLibrary,
    ),
  },
);
