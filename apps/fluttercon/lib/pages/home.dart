import 'package:fluttercon/components/card.dart';
import 'package:jaspr/jaspr.dart';

import '../models/session.dart';

@client
class Home extends StatelessComponent {
  Home({required this.sessions, super.key});

  final List<Session> sessions;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield ul(classes: "sessions", [
      for (final session in sessions)
        li([
          SessionCard(session: session),
        ])
    ]);
  }

  static get styles => [
        css('.sessions', [
          css('&').raw({'list-style': 'none'}).box(padding: EdgeInsets.all(40.px)),
          css('li').box(margin: EdgeInsets.only(bottom: 16.px))
        ]),
        ...SessionCard.styles,
      ];
}
