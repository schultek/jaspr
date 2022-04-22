import 'package:jaspr/jaspr.dart';
import 'package:jaspr_pad/providers/docs_provider.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../models/api_models.dart';
import 'dart_service_provider.dart';
import 'edit_provider.dart';

final docIssuesProvider = StreamProvider.family((ref, String key) {
  return ref.watch(fileContentProvider(key).stream).debounce(Duration(milliseconds: 500)).asyncMap((source) async {
    var result = await ref.read(dartServiceProvider).analyze(source);
    return result.issues..sort();
  });
});

final issuesProvider = Provider((ref) {
  if (!kIsWeb) return [];

  var gist = ref.watch(mutableGistProvider);

  var issues = <Issue>[];

  for (var key in gist.files.keys) {
    if (gist.files[key]!.type == 'application/vnd.dart') {
      var docIssues = ref.watch(docIssuesProvider(key));
      issues.addAll(docIssues.value ?? []);
    }
  }

  return issues;
});
