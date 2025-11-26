import 'dart:async';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:jaspr/jaspr.dart';

import '../models/session.dart';
@Import.onWeb('package:shared_preferences/shared_preferences.dart', show: [#SharedPreferences])
import 'favorites.imports.dart';

class FavoritesService extends ChangeNotifier {
  static FavoritesService instance = FavoritesService();

  FavoritesService() {
    SessionMapper.ensureInitialized();
    if (kIsWeb) {
      prefs = SharedPreferences.getInstance()
        ..then((preferences) {
          _favorites = MapperContainer.globals.fromJson(preferences.getString('favorites') ?? '{}');
          notifyListeners();
        });
    } else {
      prefs = Completer<SharedPreferencesOrStubbed>().future;
    }
  }

  late Future<SharedPreferencesOrStubbed> prefs;

  Map<String, Session> _favorites = {};
  Map<String, Session> get favorites => _favorites;

  void toggle(Session session) async {
    await prefs;
    if (_favorites.containsKey(session.id)) {
      _favorites.remove(session.id);
    } else {
      _favorites[session.id] = session;
    }

    (await prefs).setString('favorites', MapperContainer.globals.toJson(_favorites));

    notifyListeners();
  }
}
