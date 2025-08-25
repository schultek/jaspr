import 'package:jaspr/jaspr.dart';

import '../components/pages_nav.dart';
import '../components/session_list.dart';
import '../models/session.dart';

class SchedulePage extends StatelessComponent {
  SchedulePage({required this.day, required this.sessions, super.key});

  final int day;
  final List<Session> sessions;

  @override
  Component build(BuildContext context) {
    return Fragment(children: [
      Document.head(meta: {
        'description': "Schedule of all sessions on day $day.",
        'keywords': "Fluttercon, Sessions, Jaspr, Dart, Flutter",
        'og:title': "Fluttercon Berlin 2024 - Schedule for Day $day",
        'og:image': "https://sessionize.com/image/1314-1140o400o3-h467LSBSMTzb8do1dJniEh.jpg"
      }),
      PagesNav(day: day),
      SessionList(sessions: sessions),
      footer([
        text('💙 Built with '),
        a(href: "https://github.com/schultek/jaspr", [text('Jaspr')]),
        text('💙'),
        br(),
        text('Join '),
        a(href: "/jaspr_unleashing_the_power_of_dart_for_modern_web_development_642677", [text('my talk')]),
        text(' to see this website being built live.'),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
        css('footer').styles(
          margin: Margin.all(40.px),
          textAlign: TextAlign.center,
          fontStyle: FontStyle.italic,
        ),
      ];
}
