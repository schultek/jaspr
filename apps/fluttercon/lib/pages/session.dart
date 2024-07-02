import 'package:jaspr/jaspr.dart';

import '../components/tag.dart';
import '../models/session.dart';

class SessionPage extends StatelessComponent {
  const SessionPage({required this.session, super.key});

  final Session session;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Head(meta: {
      'description': session.description,
      'keywords': "Fluttercon, Sessions, Jaspr, Dart, Flutter",
      'og:title': session.title,
      'og:image': "https://sessionize.com/image/1314-1140o400o3-h467LSBSMTzb8do1dJniEh.jpg"
    });

    yield section(classes: 'session', [
      a(href: '/', [text('Home')]),
      h1([text(session.title)]),
      span([text(session.timeFormatted)]),
      div([
        Tag(label: session.format),
        Tag(label: session.room),
        Tag(label: session.durationFormatted),
      ]),
      h3([text("Speaker${session.speakers.length > 1 ? 's' : ''}")]),
      ul([
        for (final speaker in session.speakers)
          li([
            text(speaker.name),
          ]),
      ]),
      h3([text("Description")]),
      p([text(session.description)]),
    ]);
  }

  static get styles => [
        css('section.session', [
          css('&')
              .box(padding: EdgeInsets.all(40.px))
              .flexbox(
                direction: FlexDirection.column,
                justifyContent: JustifyContent.center,
                alignItems: AlignItems.center,
              )
              .text(align: TextAlign.center),
          css('a').flexItem(alignSelf: AlignSelf.start).text(color: Color.initial),
          css('h1').box(margin: EdgeInsets.only(top: 40.px, bottom: 20.px)).text(fontSize: 2.em),
          css('div').box(margin: EdgeInsets.symmetric(vertical: 20.px)),
          css('ul').list(style: ListStyle.none).box(padding: EdgeInsets.zero),
          css('p').text(align: TextAlign.justify, whiteSpace: WhiteSpace.preLine),
        ]),
      ];
}
