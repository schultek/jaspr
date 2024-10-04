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
  // [Document] renders the root document structure (<html>, <head> and <body>)
  // with the provided parameters and components.
  runApp(Document(
    title: '{{name}}',
    styles: [
      // Special import rule to include to another css file.
      css.import('https://fonts.googleapis.com/css?family=Roboto'),
      // Each style rule takes a valid css selector and a set of styles.
      // Styles are defined using type-safe css bindings and can be freely chained and nested.
      css('html, body')
          .text(fontFamily: const FontFamily.list([FontFamily('Roboto'), FontFamilies.sansSerif]))
          .box(width: 100.percent, minHeight: 100.vh)
          .box(margin: EdgeInsets.zero, padding: EdgeInsets.zero),
      css('h1').text(fontSize: 4.rem).box(margin: EdgeInsets.unset),
    ],{{^hydration}}
    head: [
      // Links to the compiled client entrypoint.
      script(defer: true, src: 'main.dart.js', []),{{#flutter}}
      // The generated flutter manifest and bootstrap script.
      link(rel: 'manifest', href: 'manifest.json'),
      script(src: "flutter_bootstrap.js", async: true, []),{{/flutter}}
    ],{{/hydration}}{{#hydration}}{{#flutter}}
    head: [
      // The generated flutter manifest and bootstrap script.
      link(rel: 'manifest', href: 'manifest.json'),
      script(src: "flutter_bootstrap.js", async: true, []),
    ],{{/flutter}}{{/hydration}}
    body: App(),
  ));
}
