import 'package:jaspr/dom.dart';

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
      span([.text(session.timeFormatted)]),
      h2([.text(session.title)]),
      p([.text(session.speakers.map((sp) => sp.name).join(', '))]),
      div([Tag(label: session.room), Tag(label: session.format), Tag(label: session.durationFormatted)]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.session-card', [
      css('&').styles(
        display: .block,
        position: .relative(),
        padding: .all(16.px),
        border: .none,
        radius: .all(.circular(12.px)),
        color: .initial,
        textDecoration: .new(line: .none),
      ),
      css('&:hover').styles(backgroundColor: Color('#0001')),
      css('span').styles(fontSize: 0.7.em),
      css('h2').styles(
        margin: .symmetric(vertical: 4.px),
        fontSize: 1.2.em,
      ),
      css('div').styles(display: .flex),
      css('button').styles(
        position: .absolute(right: 10.px, top: 10.px),
      ),
    ]),
  ];
}
