// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:dart_quotes_server/web/components/quote_like_button.dart'
    deferred as _quote_like_button;
import 'package:file_picker/_internal/file_picker_web.dart' as _file_picker_web;
import 'package:google_sign_in_web/google_sign_in_web.dart'
    as _google_sign_in_web;
import 'package:image_cropper_for_web/image_cropper_for_web.dart'
    as _image_cropper_for_web;
import 'package:image_picker_for_web/image_picker_for_web.dart'
    as _image_picker_for_web;
import 'package:shared_preferences_web/shared_preferences_web.dart'
    as _shared_preferences_web;

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
ClientOptions get defaultClientOptions => ClientOptions(
  initialize: () {
    final Registrar registrar = webPluginRegistrar;
    _file_picker_web.FilePickerWeb.registerWith(registrar);
    _google_sign_in_web.GoogleSignInPlugin.registerWith(registrar);
    _image_cropper_for_web.ImageCropperPlugin.registerWith(registrar);
    _image_picker_for_web.ImagePickerPlugin.registerWith(registrar);
    _shared_preferences_web.SharedPreferencesPlugin.registerWith(registrar);
    registrar.registerMessageHandler();
  },
  clients: {
    'quote_like_button': ClientLoader(
      (p) => _quote_like_button.QuoteLikeButton(
        id: p['id'] as int,
        initialCount: p['initialCount'] as int,
      ),
      loader: _quote_like_button.loadLibrary,
    ),
  },
);
