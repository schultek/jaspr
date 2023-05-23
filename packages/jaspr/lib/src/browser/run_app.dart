import '../framework/framework.dart';
import 'browser_binding.dart';

/// Main entry point for the browser app
BrowserAppBinding runApp(Component app, {String attachTo = 'body'}) {
  return BrowserAppBinding()..attachRootComponent(app, attachTo: attachTo);
}
