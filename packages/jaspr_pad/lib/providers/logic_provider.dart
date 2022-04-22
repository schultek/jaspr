import 'package:jaspr_pad/adapters/html.dart';
import 'package:jaspr_pad/components/playground/output/execution_service.dart';
import 'package:jaspr_pad/main.mapper.g.dart';
import 'package:jaspr_pad/providers/dart_service_provider.dart';
import 'package:jaspr_pad/providers/edit_provider.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'gist_provider.dart';

final isCompilingProvider = StateProvider((ref) => false);

final logicProvider = Provider((ref) => Logic(ref));

class Logic {
  Logic(this.ref);
  final Ref ref;

  void newPad() async {
    ref.read(storageProvider).remove('gist');
    window.history.pushState(null, 'JasprPad', window.location.origin);
    ref.refresh(gistProvider);
  }

  void refresh() {
    ref.read(storageProvider).remove('gist');
    ref.refresh(gistProvider);
  }

  Future<void> formatDartFiles() async {
    var gist = ref.read(mutableGistProvider);

    await Future.wait([
      for (var key in gist.files.keys)
        if (gist.files[key]!.type == 'application/vnd.dart')
          ref.read(dartServiceProvider).format(gist.files[key]!.content).then((res) => ref
              .read(mutableGistProvider.notifier)
              .update((state) => state.copyWith.files.get(key)!.call(content: res.newString))),
    ]);
  }

  Future<void> compileFiles() async {
    ref.read(isCompilingProvider.notifier).state = true;
    var gist = ref.read(mutableGistProvider);

    try {
      var response = await ref.read(dartServiceProvider).compile({
        for (var key in gist.files.keys)
          if (gist.files[key]!.type == 'application/vnd.dart') key: gist.files[key]!.content,
      });

      if (response.result != null) {
        var executionService = ref.read(executionProvider);
        if (executionService == null) return;

        var htmlSource = gist.files['index.html']!.content;
        var cssSource = gist.files['styles.css']!.content;

        await executionService.execute(
          htmlSource,
          cssSource,
          response.result!,
          destroyFrame: false,
        );
      } else if (response.error != null) {
        ref.read(consoleMessagesProvider.notifier).update((l) => [...l, response.error!]);
      }
    } finally {
      ref.read(isCompilingProvider.notifier).state = false;
    }
  }

  Future<void> document(String source, int index) async {
    var response = await ref.read(dartServiceProvider).document(source, index);
    ref.read(activeDocumentationProvider.notifier).state = response.info;
  }
}
