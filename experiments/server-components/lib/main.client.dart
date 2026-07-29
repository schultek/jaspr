// The entrypoint for the **client** environment.
//
// The [main] method will only be executed on the client after loading the page.

// Client-specific Jaspr import.
import 'package:jaspr/client.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'main.client.options.dart';

void main() {
  // Initializes the client environment with the generated default options.
  Jaspr.initializeApp(
    options: defaultClientOptions,
  );

  // Starts the app.
  //
  // [ClientApp] automatically loads and renders all components annotated with @client.
  //
  // You can wrap this with additional [InheritedComponent]s to share state across multiple 
  // @client components if needed.
  runApp(
    const ClientApp(),
  );
}
