import 'dart:async';

import 'package:jaspr/jaspr.dart';

@Import.onWeb('package:shared_preferences/shared_preferences.dart', show: [#SharedPreferences])
import 'favorites.imports.dart';

class FavoritesService extends ChangeNotifier {
  static FavoritesService instance = FavoritesService();

  FavoritesService() {
    if (kIsWeb) {
      prefs = SharedPreferences.getInstance()
        ..then((p) {
          _favorites = p.getStringList('favorites')?.toSet() ?? {};
          notifyListeners();
        });
    } else {
      prefs = Completer<SharedPreferencesOrStubbed>().future;
    }
  }

  late Future<SharedPreferencesOrStubbed> prefs;

  Set<String> _favorites = {};
  Set<String> get favorites => _favorites;

  void toggle(String id) async {
    await prefs;
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }

    (await prefs).setStringList('favorites', _favorites.toList());

    notifyListeners();
  }
}
