import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../adapters/html.dart';
import '../components/playground/output/execution_service.dart';
import '../main.mapper.g.dart';
import '../models/sample.dart';
import 'dart_service_provider.dart';
import 'docu_provider.dart';
import 'edit_provider.dart';
import 'project_provider.dart';

final isCompilingProvider = StateProvider((ref) => false);

final logicProvider = Provider((ref) => Logic(ref));

class Logic {
  Logic(this.ref);
  final Ref ref;

  void newPad() async {
    ref.read(storageProvider).remove('project');
    window.history.pushState(null, 'JasprPad', window.location.origin);
    ref.refresh(loadedProjectProvider);
  }

  void refresh() {
    ref.read(storageProvider).remove('project');
    ref.refresh(loadedProjectProvider);
  }

  void selectSample(Sample data) async {
    ref.read(storageProvider).remove('project');
    window.history.pushState(null, 'JasprPad', window.location.origin + '?sample=${data.id}');
    ref.refresh(loadedProjectProvider);
  }

  Future<void> formatDartFiles() async {
    var proj = ref.read(editProjectProvider);

    if (proj == null) return;

    await Future.wait([
      for (var e in proj.allDartFiles.entries)
        ref.read(dartServiceProvider).format(e.value).then((res) =>
            ref.read(editProjectProvider.notifier).update((state) => state?.updateContent(e.key, res.newString))),
    ]);
  }

  Future<void> compileFiles() async {
    ref.read(isCompilingProvider.notifier).state = true;
    var proj = ref.read(editProjectProvider);

    if (proj == null) return;

    try {
      var response = await ref.read(dartServiceProvider).compile(proj.allDartFiles);

      if (response.result != null) {
        var executionService = ref.read(executionProvider);
        if (executionService == null) return;

        await executionService.execute(
          proj.htmlFile,
          proj.cssFile,
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

  Future<void> document(String name, int index) async {
    var proj = ref.read(editProjectProvider);
    if (proj == null) return;
    var response = await ref.read(dartServiceProvider).document(proj.allDartFiles, name, index);
    ref.read(activeDocumentationProvider.notifier).state = response.info;
  }

  void downloadProject() {
    var currentProject = ref.read(editProjectProvider);
    if (currentProject == null) return;

    var doc = window.document as HtmlDocument;
    var element = doc.createElement('a');
    element.setAttribute(
        'href', '${window.location.origin}/api/download?project=${stateCodec.encode(Mapper.toValue(currentProject))}');
    element.setAttribute('download', 'jaspr_${currentProject.id}.zip');

    element.style.display = 'none';
    doc.body?.append(element);

    element.click();

    element.remove();
  }

  void addNewFile(String result) {
    ref.read(editProjectProvider.notifier).update((proj) => proj?.updateContent(result, ''));
  }

  void deleteFile(String key) {
    ref.read(editProjectProvider.notifier).update((proj) => proj?.updateContent(key, null));
  }
}
