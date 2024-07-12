import 'package:collection/collection.dart';
import 'package:jaspr/jaspr.dart';

import '../models/session.dart';
import 'session_card.dart';

class SessionList extends StatelessComponent {
  const SessionList({required this.sessions, super.key});

  final List<Session> sessions;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var groups = sessions.groupListsBy((s) => s.startsAt);

    yield ul(classes: "sessions", [
      for (final MapEntry(value: sessions) in groups.entries)
        div(classes: "group", [
          for (final session in sessions)
            li(key: ValueKey(session.id), [
              SessionCard(session: session),
            ]),
        ]),
    ]);
  }

  static List<StyleRule> get styles => [
        css('.sessions', [
          css('&').list(style: ListStyle.none).box(padding: EdgeInsets.symmetric(horizontal: 40.px)),
          css('li').box(margin: EdgeInsets.only(bottom: 8.px)),
          css('.group').box(
              radius: BorderRadius.circular(8.px),
              border: Border.all(BorderSide.dashed(color: Colors.gray)),
              padding: EdgeInsets.only(left: 8.px, right: 8.px, top: 8.px),
              margin: EdgeInsets.symmetric(vertical: 20.px)),
        ]),
      ];
}
