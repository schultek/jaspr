import 'package:jaspr/jaspr.dart';

import 'header.dart';

class WhatsNext extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Header();
    // Renders a <p> element with 'Hello World' content.
    yield p([
      text('Hello World'),
    ]);
  }
}
