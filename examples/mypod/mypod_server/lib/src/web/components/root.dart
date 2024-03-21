import 'package:jaspr/server.dart';

import '../../../counter.dart';

class RootComponent extends StatelessComponent {
  const RootComponent({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Document(
      title: "Built with Serverpod & Jaspr",
      head: [
        link(rel: "stylesheet", href: "/css/style.css"),
        script(src: 'main.dart.js', defer: true, []),
      ],
      body: div(classes: "content", [
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
        ]),
        div(id: "counter", [Counter()]),
        hr(),
        div(classes: "link-box", [
          a(href: "https://serverpod.dev", [text("Serverpod")]),
          text('•'),
          a(href: "https://docs.serverpod.dev", [text("Get Started")]),
          text('•'),
          a(href: "https://github.com/serverpod/serverpod", [text("Github")]),
        ])
      ]),
    );
    ;
  }
}
