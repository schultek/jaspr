import 'dart:async';

import 'package:jaspr_pad/main.mapper.g.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../adapters/codemirror.dart';
import 'gist_provider.dart';

final mutableGistProvider = Provider((ref) {
  var asyncGist = ref.watch(gistProvider);

  var docs = asyncGist.value?.files //
          .map((k, f) => MapEntry(k, Doc(f.content, _toMode(f.type)))) ??
      {};

  if (asyncGist.value != null) {
    for (var key in docs.keys) {
      var doc = docs[key]!;

      doc.onChange.debounce(Duration(seconds: 1)).listen((data) {
        ref.read(storageProvider)['gist'] = asyncGist.value!.copyWith.files
            .apply((f) => f.map((k, v) => MapEntry(k, v.copyWith(content: docs[k]!.getValue()!))))
            .toJson();
      });
    }
  }

  return MutableGist(asyncGist.value, docs);
});

extension DebounceStream<T> on Stream<T> {
  Stream<T> debounce(Duration duration) {
    Timer? timer;
    return transform(StreamTransformer.fromHandlers(handleData: (data, sink) {
      timer?.cancel();
      timer = Timer(duration, () {
        sink.add(data);
      });
    }));
  }
}

String _toMode(String type) {
  switch (type) {
    case 'text/html':
      return 'text/html';
    case 'application/vnd.dart':
      return 'dart';
    case 'text/css':
      return 'css';
    default:
      return 'text';
  }
}

class MutableGist {
  final GistData? gist;
  final Map<String, Doc> docs;

  MutableGist(this.gist, this.docs);
}
