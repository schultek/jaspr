import 'dart:async';

import 'package:collection/collection.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_riverpod/legacy.dart';

import '../models/api_models.dart';
import '../models/project.dart';
import '../models/tutorial.dart';
import 'project_provider.dart';
import 'utils.dart';

final editProjectProvider = NotifierProvider<EditProjectNotifier, ProjectDataBase?>(
  EditProjectNotifier.new,
  name: 'editProject',
);

class EditProjectNotifier extends Notifier<ProjectDataBase?> {
  @override
  ProjectDataBase? build() {
    var loadedProject = ref.watch(loadedProjectProvider).value;

    if (kIsWeb) {
      var update = debounce((ProjectDataBase? project) {
        if (project != null) {
          ref.read(storageProvider)['project'] = project.toJson();
        }
      }, Duration(seconds: 1));

      listenSelf((_, data) => update(data));
    }

    return loadedProject;
  }

  void updateContent(String key, String? content) {
    state = state?.updateContent(key, content);
  }

  void toggleSolution() {
    state = (state as TutorialData).toggleSolution();
  }

  void updateProject(TutorialData updated) {
    state = updated;
  }
}

final fileSelectionProvider = StateProvider.family<IssueLocation?, String>((ref, String key) => null);

final activeDocIndexProvider = StateProvider((ref) => 0, name: 'activeDocIndex');

final activeDocKeyProvider = Provider((ref) {
  var index = ref.watch(activeDocIndexProvider);
  return ref.watch(fileNamesProvider).skip(index).firstOrNull;
}, name: 'activeDocKey');

final fileNamesProvider = Provider((ref) {
  if (!kIsWeb) return <String>[];
  return ref.watch(editProjectProvider)?.fileNames ?? [];
}, name: 'fileNames');

final fileContentProvider = StreamProvider.family((ref, String key) {
  var c = StreamController<String>();
  var sub = ref.listen<String>(editProjectProvider.select((proj) => proj?.fileContentFor(key) ?? ''), (_, next) {
    c.add(next);
  }, fireImmediately: true);
  ref.onDispose(() {
    sub.close();
    c.close();
  });
  return c.stream;
}, name: 'fileContent');
