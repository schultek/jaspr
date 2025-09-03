import 'package:jaspr/jaspr.dart';

import '../models/session.dart';
import 'like_button.dart';
import 'tag.dart';

class SessionCard extends StatelessComponent {
  const SessionCard({required this.session, super.key});

  final Session session;

  @override
  Component build(BuildContext context) {
    return a(href: '/${session.slug}', classes: "session-card", [
      LikeButton(session: session),
      span([text(session.timeFormatted)]),
      h2([text(session.title)]),
      p([text(session.speakers.map((s) => s.name).join(', '))]),
      div([
        Tag(label: session.room),
        Tag(label: session.format),
        Tag(label: session.durationFormatted),
      ])
    ]);
  }

  @css
  static List<StyleRule> get styles => [
        css('.session-card', [
          css('&').styles(
            display: Display.block,
            position: Position.relative(),
            padding: Padding.all(16.px),
            border: Border(),
            radius: BorderRadius.all(Radius.circular(12.px)),
            color: Color.initial,
            textDecoration: TextDecoration(line: TextDecorationLine.none),
          ),
          css('&:hover').styles(
            backgroundColor: Color('#0001'),
          ),
          css('span').styles(
            fontSize: 0.7.em,
          ),
          css('h2').styles(
            margin: Margin.symmetric(vertical: 4.px),
            fontSize: 1.2.em,
          ),
          css('div').styles(
            display: Display.flex,
          ),
          css('button').styles(
            position: Position.absolute(right: 10.px, top: 10.px),
          ),
        ]),
      ];
}
