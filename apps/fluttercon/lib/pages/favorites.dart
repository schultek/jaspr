import 'package:jaspr/jaspr.dart';

import '../components/pages_nav.dart';
import '../components/session_list.dart';
import '../services/favorites.dart';

@client
class FavoritesPage extends StatelessComponent {
  const FavoritesPage({super.key});

  @override
  Component build(BuildContext context) {
    return .fragment([
      PagesNav(),
      ListenableBuilder(
        listenable: FavoritesService.instance,
        builder: (context) {
          var favorites = FavoritesService.instance.favorites.values.toList();
          favorites.sort((fa, fb) => fa.startsAt.compareTo(fb.startsAt));
          return SessionList(sessions: favorites);
        },
      ),
    ]);
  }
}
