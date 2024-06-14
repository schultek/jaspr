import 'package:jaspr/server.dart';
import 'package:server_components/jaspr_options.dart';

import './app.dart';

void main() {
  Jaspr.initializeApp(options: defaultJasprOptions);

  runApp(Document(
    title: 'server_components',
    styles: [
      StyleRule.import('https://fonts.googleapis.com/css?family=Roboto'),
      css('html, body')
          .text(fontFamily: FontFamily.list([FontFamily('Roboto'), FontFamilies.sansSerif]))
          .box(width: 100.percent, height: 100.percent, margin: EdgeInsets.zero, padding: EdgeInsets.zero),
    ],
    body: App(
      name: "Kilian1",
      child: p(classes: "server", [
        text('Hello from Server'),
        App(
          name: "Kilian2",
          child: span([text('Hi from Server')]),
        )
      ]),
    ),
  ));
}
