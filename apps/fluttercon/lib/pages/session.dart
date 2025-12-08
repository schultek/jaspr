import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/tag.dart';
import '../models/session.dart';

class SessionPage extends StatelessComponent {
  const SessionPage({required this.session, super.key});

  final Session session;

  @override
  Component build(BuildContext context) {
    return .fragment([
      Document.head(
        meta: {
          'description': session.description,
          'keywords': "Fluttercon, Sessions, Jaspr, Dart, Flutter",
          'og:title': session.title,
          'og:image': "https://sessionize.com/image/1314-1140o400o3-h467LSBSMTzb8do1dJniEh.jpg",
        },
      ),
      section(classes: 'session', [
        a(href: '/', [.text('Home')]),
        h1([.text(session.title)]),
        span([.text(session.timeFormatted)]),
        div([Tag(label: session.format), Tag(label: session.room), Tag(label: session.durationFormatted)]),
        h3([.text("Speaker${session.speakers.length > 1 ? 's' : ''}")]),
        ul([
          for (final speaker in session.speakers) li([.text(speaker.name)]),
        ]),
        h3([.text("Description")]),
        p([.text(session.description)]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('section.session', [
      css('&').styles(
        display: .flex,
        padding: .all(40.px),
        flexDirection: .column,
        justifyContent: .center,
        alignItems: .center,
        textAlign: .center,
      ),
      css('a').styles(
        alignSelf: .start,
        color: .initial,
      ),
      css('h1').styles(
        margin: .only(top: 40.px, bottom: 20.px),
        fontSize: 2.em,
      ),
      css('div').styles(margin: .symmetric(vertical: 20.px)),
      css('ul').styles(padding: .zero, listStyle: .none),
      css('p').styles(textAlign: .justify, whiteSpace: .preLine),
    ]),
  ];
}
