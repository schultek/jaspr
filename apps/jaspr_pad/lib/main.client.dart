// The entrypoint for the **client** environment.
//
// The [main] method will only be executed on the client after loading the page.

// Client-specific Jaspr import.
import 'package:jaspr/client.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'components/playground/playground.dart';
import 'main.client.options.dart';

void main() {
  // Initializes the client environment with the generated default options.
  Jaspr.initializeApp(
    options: defaultClientOptions,
  );

  runApp(ProviderScope(child: Playground()));
}
