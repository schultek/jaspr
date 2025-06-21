import 'package:jaspr/server.dart';

import 'components/app.dart';
import 'jaspr_options.dart';

/// Entrypoint for the server
void main() async {
  Jaspr.initializeApp(
    options: defaultJasprOptions,
  );

  runApp(
    Document(body: App()),
  );
}

@css
List<StyleRule> get styles => [
      css('.main').styles(minWidth: 12.px),
      css.media(MediaQuery.screen(minWidth: 200.px), []),
    ];
