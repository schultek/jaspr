// The entrypoint for the **client** environment.
//
// This file is compiled to javascript and executed in the browser.

// Client-specific jaspr import.
import 'package:jaspr/browser.dart';
// Imports the [App] component.
import 'package:{{name}}/app.dart';

void main() {
  // Attaches the [App] component to the <body> of the page.
  runApp(App());
}
