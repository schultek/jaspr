import 'package:jaspr/jaspr.dart';
import 'package:jaspr_pad/providers/docs_provider.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../adapters/codemirror.dart';
import '../models/api_models.dart';
import 'dart_service_provider.dart';
import 'edit_provider.dart';

final docIssuesProvider = StreamProvider.family((ref, String key) {
  ref.listenSelf((_, value) {
    var doc = ref.read(docProvider(key));
    var issues = value.value ?? [];

    for (final marker in doc.getAllMarks()) {
      marker.clear();
    }

    for (final issue in issues) {
      // Create in-line squiggles.
      doc.markText(Position(issue.location.startLine, issue.location.startColumn),
          Position(issue.location.endLine, issue.location.endColumn),
          className: 'squiggle-${issue.kind.name}', title: issue.message);
    }
  });

  return ref.watch(docContentProvider(key).stream).debounce(Duration(milliseconds: 500)).asyncMap((source) async {
    var result = await ref.read(dartServiceProvider).analyze(source);
    return result.issues..sort();
  });
});

final issuesProvider = Provider((ref) {
  if (!kIsWeb) return [];

  var gist = ref.watch(mutableGistProvider);

  var issues = <Issue>[];

  for (var key in gist.gist?.files.keys ?? <String>[]) {
    if (gist.gist?.files[key]!.type == 'application/vnd.dart') {
      var docIssues = ref.watch(docIssuesProvider(key));
      issues.addAll(docIssues.value ?? []);
    }
  }

  return issues;
});
