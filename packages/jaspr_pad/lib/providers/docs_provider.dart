import 'dart:async';

import 'package:collection/collection.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import './edit_provider.dart';

final activeDocIndexProvider = StateProvider((ref) => 0);

final activeDocKeyProvider = Provider((ref) {
  var index = ref.watch(activeDocIndexProvider);
  return ref.watch(fileNamesProvider).skip(index).firstOrNull ?? '';
});

final fileNamesProvider = Provider((ref) {
  if (!kIsWeb) return <String>[];
  return ref.watch(mutableGistProvider).files.keys.toList();
});

final fileContentProvider = StreamProvider.family((ref, String key) {
  var c = StreamController<String>();
  var sub = ref.listen<String>(mutableGistProvider.select((gist) => gist.files[key]?.content ?? ''), (_, next) {
    c.add(next);
  }, fireImmediately: true);
  ref.onDispose(() {
    sub.close();
    c.close();
  });
  return c.stream;
});
