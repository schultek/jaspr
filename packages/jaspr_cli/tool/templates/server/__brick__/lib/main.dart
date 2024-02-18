import 'package:jaspr/server.dart';

import 'components/app.dart';
import 'styles.dart';

void main() {
  Jaspr.initializeApp();

  runApp(Document(
    title: '{{name}}',
    styles: styles,
    body: App(),
  ));
}
