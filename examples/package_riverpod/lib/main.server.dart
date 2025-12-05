import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'components/app.dart';
import 'main.server.options.dart';

/// Entrypoint for the server
void main() async {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(Document(body: App()));
}

@css
List<StyleRule> get styles => [
  css('.main').styles(minWidth: 12.px),
  css.media(.screen(minWidth: 200.px), []),
];
