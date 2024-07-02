import 'dart:convert';
import 'dart:io';

import 'package:fluttercon/pages/favorites.dart';
import 'package:http/http.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'models/session.dart';
import 'pages/schedule.dart';
import 'pages/session.dart';

// A simple [StatelessComponent] with a [build] method.
class App extends AsyncStatelessComponent {
  @override
  Stream<Component> build(BuildContext context) async* {
    final List<Session> sessions;

    if (File('sessions.json').existsSync()) {
      sessions =
          (jsonDecode(File('sessions.json').readAsStringSync()) as List).map((s) => SessionMapper.fromMap(s)).toList();
    } else {
      final response = await get(Uri.parse('https://sessionize.com/api/v2/aje9iuav/view/Sessions'));

      final [{"sessions": sessionsJson}] = jsonDecode(response.body) as List;
      sessions = (sessionsJson as List).map((s) => SessionMapper.fromMap(s)).toList();
      File('sessions.json').writeAsStringSync(jsonEncode(sessionsJson));
    }

    yield div(classes: 'main', [
      Router(
          redirect: (context, state) {
            if (state.location == '/') return '/day-1';
            return null;
          },
          routes: [
            for (var i = 1; i < 4; i++)
              Route(
                path: '/day-$i',
                title: 'Fluttercon Berlin 2024',
                builder: (context, state) => SchedulePage(
                  day: i,
                  sessions: sessions.where((s) => s.startsAt.day == i + 2).toList(),
                ),
              ),
            Route(path: '/favorites', title: 'Favorites', builder: (context, state) => FavoritesPage()),
            for (var session in sessions)
              Route(
                path: '/${session.slug}',
                title: session.title,
                builder: (context, state) => SessionPage(session: session),
              ),
          ]),
    ]);
  }

  static get styles => [
        css('.main').box(minHeight: 100.vh),
        ...SchedulePage.styles,
        ...SessionPage.styles,
      ];
}
