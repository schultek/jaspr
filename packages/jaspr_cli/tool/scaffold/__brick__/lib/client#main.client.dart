// The entrypoint for the **client** app.
//
// This file is compiled to javascript and executed in the browser.

// Client-specific Jaspr import.
import 'package:jaspr/browser.dart';
// Imports the [App] component.
import 'app.dart';

void main() {
  // Attaches the [App] component to the <body> of the page.
  runApp(App());
}
