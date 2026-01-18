import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/theme.dart';

import 'layouts/home_layout.dart';
import 'layouts/imprint_layout.dart';
import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(
    ContentApp(
      parsers: [
        MarkdownParser(),
      ],
      layouts: [
        HomeLayout(),
        ImprintLayout(),
      ],
      theme: ContentTheme.none(),
    ),
  );
}
