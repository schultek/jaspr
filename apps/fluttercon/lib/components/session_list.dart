import 'package:collection/collection.dart';
import 'package:jaspr/jaspr.dart';

import '../models/session.dart';
import 'session_card.dart';

class SessionList extends StatelessComponent {
  const SessionList({required this.sessions, super.key});

  final List<Session> sessions;

  @override
  Component build(BuildContext context) {
    var groups = sessions.groupListsBy((s) => s.startsAt);

    return ul(classes: "sessions", [
      for (final MapEntry(value: sessions) in groups.entries)
        div(classes: "group", [
          for (final session in sessions) li(key: ValueKey(session.id), [SessionCard(session: session)]),
        ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.sessions', [
      css('&').styles(
        padding: Padding.symmetric(horizontal: 40.px),
        listStyle: ListStyle.none,
      ),
      css('li').styles(margin: Margin.only(bottom: 8.px)),
      css('.group').styles(
        padding: Padding.only(left: 8.px, right: 8.px, top: 8.px),
        margin: Margin.symmetric(vertical: 20.px),
        border: Border(style: BorderStyle.dashed, color: Colors.gray),
        radius: BorderRadius.circular(8.px),
      ),
    ]),
  ];
}
