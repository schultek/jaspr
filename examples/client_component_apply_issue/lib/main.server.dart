import 'package:jaspr/server.dart';

import 'components/inner.dart';
import 'components/outer.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultServerOptions,
  );

  runApp(
    const Outer(
      child: InnerButton(),
    ),
  );
}
