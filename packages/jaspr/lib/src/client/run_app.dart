import '../framework/framework.dart';
import 'client_binding.dart';

/// Main entry point for the browser app.
ClientAppBinding runApp(Component app, {String attachTo = 'body'}) {
  final binding = ClientAppBinding();
  Future.microtask(() => binding.attachRootComponent(app, attachTo: attachTo));
  return binding;
}
