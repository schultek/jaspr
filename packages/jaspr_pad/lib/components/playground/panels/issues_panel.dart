import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../../models/api_models.dart';
import '../../../providers/edit_provider.dart';
import '../../../providers/issues_provider.dart';

class IssuesPanel extends StatelessComponent {
  const IssuesPanel({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var issues = context.watch(issuesProvider);

    yield DomComponent(
      tag: 'div',
      styles: {'display': 'flex', 'flex-direction': 'column'},
      children: [
        for (var issue in issues) IssueItem(issue),
      ],
    );
  }
}

class IssueItem extends StatelessComponent {
  const IssueItem(this.issue, {Key? key}) : super(key: key);

  final Issue issue;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'span',
      classes: ['issue-item', issue.kind.name],
      events: {
        'click': (e) {
          context.read(fileSelectionProvider(issue.sourceName).notifier).state = issue.location;
          context.read(activeDocIndexProvider.notifier).state =
              context.read(fileNamesProvider).indexOf(issue.sourceName);
        }
      },
      children: [
        DomComponent(
          tag: 'i',
          classes: ['material-icons'],
          child: Text(issue.kind.name),
        ),
        Text(issue.message),
      ],
    );
  }
}
