import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../../models/api_models.dart';
import '../../../providers/edit_provider.dart';
import '../../../providers/issues_provider.dart';

class IssuesPanel extends StatelessComponent {
  const IssuesPanel({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var issues = context.watch(issuesProvider);

    yield div(styles: Styles.flexbox(direction: FlexDirection.column), [
      for (var issue in issues) IssueItem(issue),
    ]);
  }
}

class IssueItem extends StatelessComponent {
  const IssueItem(this.issue, {super.key});

  final Issue issue;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield span(classes: 'issue-item ${issue.kind.name}', events: events(onClick: () {
      context.read(fileSelectionProvider(issue.sourceName).notifier).state = issue.location;
      context.read(activeDocIndexProvider.notifier).state = context.read(fileNamesProvider).indexOf(issue.sourceName);
    }), [
      i(classes: 'material-icons', [text(issue.kind.name)]),
      text(issue.message),
    ]);
  }
}
