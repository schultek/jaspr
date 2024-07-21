// The entrypoint for the **server** environment.
//
// The [main] method will only be executed on the server during pre-rendering.
// To run code on the client, {{^hydration}}see [web/main.dart]{{/hydration}}{{#hydration}}use the @client annotation{{/hydration}}.

// Server-specific jaspr import.
import 'package:jaspr/server.dart';

// Imports the [App] component.
import 'app.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'jaspr_options.dart';

void main() {
  // Initializes the server environment with the generated default options.
  Jaspr.initializeApp(
    options: defaultJasprOptions,
  );

  // Starts the app.
  //
  // [Document] renders the root document structure (<html><head><body>) with
  // the provided parameters.
  runApp(Document(
    title: '{{name}}',{{^hydration}}
    // Components rendered inside <head>.
    head: [
      // Links to the compiled client entrypoint.
      script(defer: true, src: 'main.dart.js', []),{{#flutter}}
      // The generated flutter manifest.
      link(rel: 'manifest', href: 'manifest.json'),{{/flutter}}
    ],{{/hydration}}{{#hydration}}{{#flutter}}
    // Components rendered inside <head>.
    head: [
      // The generated flutter manifest.
      link(rel: 'manifest', href: 'manifest.json'),
    ],{{/flutter}}{{/hydration}}
    // The component to render inside <body>.
    body: App(),
  ));
}
