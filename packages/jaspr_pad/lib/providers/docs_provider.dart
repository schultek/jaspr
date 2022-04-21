import 'package:collection/collection.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import './edit_provider.dart';
import '../adapters/codemirror.dart';

final activeFileIndexProvider = StateProvider((ref) => 0);

final fileNamesProvider = Provider((ref) {
  if (!kIsWeb) return <String>[];
  return ref.watch(mutableGistProvider).gist?.files.keys.toList() ?? [];
});

final docProvider = Provider.family((ref, String key) {
  return ref.watch(mutableGistProvider.select((g) => g.docs[key] ?? Doc('')));
});

final docContentProvider = StreamProvider.family((ref, String key) async* {
  var doc = ref.watch(docProvider(key));
  yield doc.getValue()!;
  yield* doc.onChange.map((_) => doc.getValue()!);
});

final activeDocProvider = Provider((ref) {
  var index = ref.watch(activeFileIndexProvider);
  var key = ref.watch(fileNamesProvider).skip(index).firstOrNull ?? '';
  return ref.watch(docProvider(key));
});
