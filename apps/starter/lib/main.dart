import 'package:jaspr/server.dart';

import 'app.dart';
import 'jaspr_options.dart';
import 'styles.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultJasprOptions,
  );

  runApp(
    Builder.single(
      builder: (_) => Document(
        title: '{{name}}',
        styles: styles,
        body: App(),
      ),
    ),
  );
}
