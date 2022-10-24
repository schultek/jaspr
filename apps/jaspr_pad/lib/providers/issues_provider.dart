import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../models/api_models.dart';
import '../models/project.dart';
import 'dart_service_provider.dart';
import 'edit_provider.dart';
import 'utils.dart';

final issuesProvider = Provider<List<Issue>>((ref) {
  if (!kIsWeb) return [];

  var fetchIssues = debounce((ProjectData proj) async {
    var response = await ref.read(dartServiceProvider).analyze(proj.allDartFiles);
    ref.state = response.issues;
  }, Duration(milliseconds: 500));

  ref.listen<ProjectData?>(editProjectProvider, (_, proj) {
    if (proj != null) fetchIssues(proj);
  }, fireImmediately: true);

  return [];
}, name: 'issues');

final docIssuesProvider = Provider.family((ref, String key) {
  return ref.watch(issuesProvider.select((issues) => issues.where((i) => i.sourceName == key).toList()));
});
