import 'package:fluttercon/models/session.dart';
import 'package:jaspr/jaspr.dart';

import 'like_button.dart';
import 'tag.dart';

class SessionCard extends StatelessComponent {
  const SessionCard({required this.session, super.key});

  final Session session;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield a(href: '/${session.slug}', classes: "session-card", [
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
  static final styles = [
    css('.session-card', [
      css('&')
          .box(
            display: Display.block,
            position: Position.relative(),
            radius: BorderRadius.all(Radius.circular(12.px)),
            border: Border.all(BorderSide.solid()),
            padding: EdgeInsets.all(16.px),
          )
          .text(decoration: TextDecoration(line: TextDecorationLine.none), color: Color.initial),
      css('&:hover').background(color: Color.hex('#0001')),
      css('span').text(fontSize: 0.7.em),
      css('h2').text(fontSize: 1.2.em).box(margin: EdgeInsets.symmetric(vertical: 4.px)),
      css('div').flexbox(),
      css('button').box(position: Position.absolute(right: 10.px, top: 10.px)),
    ]),
  ];
}
