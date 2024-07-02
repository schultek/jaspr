import 'package:jaspr/jaspr.dart';

import '../components/session_card.dart';
import '../models/session.dart';

class SchedulePage extends StatelessComponent {
  SchedulePage({required this.day, required this.sessions, super.key});

  final int day;
  final List<Session> sessions;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield nav([
      a(href: '/day-1', [text("Day 1")]),
      a(href: '/day-2', [text("Day 2")]),
      a(href: '/day-3', [text("Day 3")]),
    ]);

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
