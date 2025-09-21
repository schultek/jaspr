import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../models/api_models.dart';
import '../models/project.dart';
import 'dart_service_provider.dart';
import 'edit_provider.dart';
import 'utils.dart';

final issuesProvider = NotifierProvider<IssuesNotifier, List<Issue>>(IssuesNotifier.new, name: 'issues');

class IssuesNotifier extends Notifier<List<Issue>> {
  @override
  List<Issue> build() {
    if (!kIsWeb) return [];

    var fetchIssues = debounce((ProjectDataBase proj) async {
      var response = await ref.read(dartServiceProvider).analyze(proj.allDartFiles);
      state = response.issues;
    }, Duration(milliseconds: 500));

    ref.listen<ProjectDataBase?>(editProjectProvider, (_, proj) {
      if (proj != null) fetchIssues(proj);
    }, fireImmediately: true);

    return [];
  }
}

final docIssuesProvider = Provider.family((ref, String key) {
  return ref.watch(issuesProvider.select((issues) => issues.where((i) => i.sourceName == key).toList()));
});
