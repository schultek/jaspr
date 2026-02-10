/// The entrypoint for the **client** app.
///
/// This file is compiled to javascript and executed on the client when loading the page.
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'dart:ui_web';

// Client-specific Jaspr import.
import 'package:jaspr/client.dart';
// Imports the [App] component.
import 'app.dart';

import 'main.client.options.dart';

void main() {
  bootstrapAssetManager();
  Jaspr.initializeApp(
    options: defaultClientOptions,
  );

  // Attaches the [App] component to the <body> of the page.
  runApp(App());
}
