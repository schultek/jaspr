import 'package:fluttercon/components/pages_nav.dart';
import 'package:jaspr/jaspr.dart';

import '../components/session_list.dart';
import '../services/favorites.dart';

@client
class FavoritesPage extends StatelessComponent {
  const FavoritesPage({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield PagesNav();

    yield ListenableBuilder(
      listenable: FavoritesService.instance,
      builder: (context) sync* {
        var favorites = FavoritesService.instance.favorites.values.toList();
        favorites.sort((a, b) => a.startsAt.compareTo(b.startsAt));
        yield SessionList(sessions: favorites);
      },
    );
  }
}
