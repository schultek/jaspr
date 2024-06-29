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
      css('div').box(padding: EdgeInsets.all(20.px)),
      css('.client').background(color: Colors.green),
      css('.server').background(color: Colors.blue),
    ],
    body: App(
      name: "Client 1",
      child: div(classes: "server", [
        text('Server 1'),
        App(
          name: "Client 2",
          child: div(classes: "server", [text('Server 2')]),
        )
      ]),
    ),
  ));
}
