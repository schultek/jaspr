import '../framework/framework.dart';
import 'browser_binding.dart';

/// Main entry point for the browser app
void runApp(Component app, {String attachTo = 'body'}) {
  AppBinding.ensureInitialized().attachRootComponent(app, attachTo: attachTo);
}
