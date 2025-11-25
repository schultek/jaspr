import 'package:jaspr/server.dart';

import 'components/app.dart';
import 'main.server.g.dart';

/// Entrypoint for the server
void main() async {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(Document(body: App()));
}

@css
List<StyleRule> get styles => [
  css('.main').styles(minWidth: 12.px),
  css.media(MediaQuery.screen(minWidth: 200.px), []),
];
