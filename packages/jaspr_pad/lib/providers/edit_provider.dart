import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_pad/main.mapper.g.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../main.mapper.g.dart';
import '../models/api_models.dart';
import 'gist_provider.dart';

final mutableGistProvider = StateProvider((ref) {
  var asyncGist = ref.watch(gistProvider);

  if (kIsWeb) {
    var debouncedStore = debounce((GistData gist) {
      ref.read(storageProvider)['gist'] = gist.toJson();
    }, Duration(seconds: 1));
    ref.listenSelf((_, next) => debouncedStore(next.state));
  }

  return asyncGist.value?.copyWith.files.putAll({}) ?? GistData('', '', {});
});

final fileSelectionProvider = StateProvider.family<IssueLocation?, String>((ref, String key) => null);

void Function(T) debounce<T>(void Function(T) fn, Duration duration) {
  Timer? timer;
  return (v) {
    timer?.cancel();
    timer = Timer(duration, () {
      fn(v);
    });
  };
}

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

String toMode(String type) {
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

final activeDocumentationProvider = StateProvider<HoverInfo?>((ref) => null);
