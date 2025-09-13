import 'dart:convert';

import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_riverpod/legacy.dart';

import '../adapters/html.dart';
import '../components/playground/output/execution_service.dart';
import '../models/sample.dart';
import '../models/tutorial.dart';
import 'dart_service_provider.dart';
import 'docu_provider.dart';
import 'edit_provider.dart';
import 'project_provider.dart';

final isCompilingProvider = Provider((ref) => ref.watch(compilingIdProvider) != null);
final compilingIdProvider = StateProvider<String?>((ref) => null);

final logicProvider = Provider((ref) => Logic(ref));

class Logic {
  Logic(this.ref);
  final Ref ref;

  void newPad() async {
    ref.read(storageProvider).remove('project');
    window.history.pushState(null, 'JasprPad', window.location.origin);
    _refreshProject();
  }

  void refresh() {
    ref.read(storageProvider).remove('project');
    _refreshProject();
  }

  void selectSample(Sample data) async {
    window.history.pushState(null, 'JasprPad', '${window.location.origin}?sample=${data.id}');
    _refreshProject();
  }

  void selectTutorial() async {
    window.history.pushState(null, 'JasprPad', '${window.location.origin}?tutorial=0-intro');
    _refreshProject();
  }

  void _refreshProject() {
    ref.invalidate(loadedProjectProvider);
    ref.invalidate(activeDocIndexProvider);
  }

  Future<TutorialData> changeStep(TutorialData tutorial, String newId) async {
    var newStep = tutorial.configs.indexWhere((c) => c.id == newId);
    if (tutorial.steps[newId] != null) {
      return tutorial.copyWith(currentStep: newStep);
    } else {
      var project = await ref.read(dartServiceProvider).getTutorial(newId);
      if (project.tutorial != null) {
        return tutorial.copyWith(
          currentStep: newStep,
          steps: {...tutorial.steps, newId: project.tutorial!.initialStep},
        );
      } else {
        throw project.error!;
      }
    }
  }

  void prevTutorialStep() async {
    var tut = ref.read(editProjectProvider) as TutorialData;
    var updated = await changeStep(tut, tut.configs[tut.currentStep - 1].id);
    ref.read(editProjectProvider.notifier).updateProject(updated);
    window.history.pushState(null, 'JasprPad', '${window.location.origin}?tutorial=${updated.step.id}');
    ref.invalidate(activeDocIndexProvider);
    compileFiles();
  }

  void nextTutorialStep() async {
    var tut = ref.read(editProjectProvider) as TutorialData;
    var updated = await changeStep(tut, tut.configs[tut.currentStep + 1].id);
    ref.read(editProjectProvider.notifier).updateProject(updated);
    window.history.pushState(null, 'JasprPad', '${window.location.origin}?tutorial=${updated.step.id}');
    ref.invalidate(activeDocIndexProvider);
    compileFiles();
  }

  void selectTutorialStep(String id) async {
    var tut = ref.read(editProjectProvider) as TutorialData;
    var updated = await changeStep(tut, id);
    ref.read(editProjectProvider.notifier).updateProject(updated);
    window.history.pushState(null, 'JasprPad', '${window.location.origin}?tutorial=${updated.step.id}');
    ref.invalidate(activeDocIndexProvider);
    compileFiles();
  }

  void toggleSolution() {
    ref.read(editProjectProvider.notifier).toggleSolution();
    compileFiles();
  }

  Future<void> formatDartFiles() async {
    var proj = ref.read(editProjectProvider);

    if (proj == null) return;

    await Future.wait([
      for (var e in proj.allDartFiles.entries)
        ref.read(dartServiceProvider).format(e.value).then(
          (res) {
            ref.read(editProjectProvider.notifier).updateContent(e.key, res.newString);
          },
        ),
    ]);
  }

  Future<void> compileFiles() async {
    var proj = ref.read(editProjectProvider);
    if (proj == null) return;

    ref.read(compilingIdProvider.notifier).state = proj.id;

    try {
      var response = await ref.read(dartServiceProvider).compile(proj.allDartFiles);

      if (response.result != null) {
        if (ref.read(compilingIdProvider) != proj.id) {
          return;
        }

        var executionService = ref.read(executionProvider);
        if (executionService == null) return;

        await executionService.execute(proj.htmlFile, proj.cssFile, response.result!, destroyFrame: false);
      } else if (response.error != null) {
        ref.read(consoleMessagesProvider.notifier).update((l) => [...l, response.error!]);
      }
    } finally {
      if (ref.read(compilingIdProvider) == proj.id) {
        ref.read(compilingIdProvider.notifier).state = null;
      }
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

    var projectBase64 = base64UrlEncode(utf8.encode(jsonEncode(currentProject.toMap())));

    var doc = window.document as HtmlDocumentOrStubbed;
    var element = doc.createElement('a');
    element.setAttribute('href', '${window.location.origin}/api/download?project=$projectBase64');
    element.setAttribute('download', 'jaspr_${currentProject.id}.zip');

    element.style.display = 'none';
    doc.body?.append(element);

    element.click();

    element.remove();
  }

  void addNewFile(String result) {
    ref.read(editProjectProvider.notifier).updateContent(result, '');
  }

  void deleteFile(String key) {
    ref.read(editProjectProvider.notifier).updateContent(key, null);
  }
}
