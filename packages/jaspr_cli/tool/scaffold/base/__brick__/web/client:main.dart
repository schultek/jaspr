// Any .dart file inside the /web directory is compiled to javascript
// and executed in the browser.

import 'package:jaspr/jaspr.dart';
import 'package:{{name}}/components/app.dart';

void main() {
  // Attaches the [App] component to the <body> of the page.
  runApp(App());
}
