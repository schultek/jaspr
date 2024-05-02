import 'package:jaspr/server.dart';

import 'counter.dart';

class Home extends StatelessComponent {
  const Home({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: "content", [
      div(classes: "logo-box", [
        img(
          src: "/images/serverpod-logo.svg",
          width: 160,
          styles: Styles.box(margin: EdgeInsets.only(top: 8.px, bottom: 12.px)),
        ),
        p([
          a(href: "https://serverpod.dev/", [text("Serverpod + Jaspr")])
        ])
      ]),
      hr(),
      div(classes: "info-box", [
        p([text("Served at ${DateTime.now()}")]),
        div(id: "counter", [Counter()]),
      ]),
      hr(),
      div(classes: "link-box", [
        a(href: "https://serverpod.dev", [text("Serverpod")]),
        text('•'),
        a(href: "https://docs.serverpod.dev", [text("Get Started")]),
        text('•'),
        a(href: "https://github.com/serverpod/serverpod", [text("Github")]),
      ]),
      div(classes: "link-box", [
        a(href: "https://docs.page/schultek/jaspr", [text("Jaspr")]),
        text('•'),
        a(href: "https://docs.page/schultek/jaspr/quick-start", [text("Get Started")]),
        text('•'),
        a(href: "https://github.com/schultek/jaspr", [text("Github")]),
      ])
    ]);
  }
}
