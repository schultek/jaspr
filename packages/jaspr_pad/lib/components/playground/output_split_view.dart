import 'package:jaspr/jaspr.dart';
import 'package:jaspr_pad/providers/docs_provider.dart';
import 'package:jaspr_pad/providers/issues_provider.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../models/api_models.dart';
import '../../providers/edit_provider.dart';
import '../elements/splitter.dart';
import 'output/execution_service.dart';
import 'panels/document_panel.dart';

enum OutputTabsState { closed, issues, docs, console }

final tabsStateProvider = StateProvider((ref) => OutputTabsState.closed);

class OutputSplitView extends StatelessComponent {
  const OutputSplitView({required this.child, Key? key}) : super(key: key);

  final Component child;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    context.watch(issuesProvider); // load issues
    var isClosed = context.watch(tabsStateProvider.select((s) => s == OutputTabsState.closed));

    if (isClosed) {
      yield child;
      yield EditorTabs();
    } else {
      yield Splitter(
        horizontal: false,
        initialSizes: [70, 30],
        children: [
          child,
          EditorTabs(),
        ],
      );
    }
  }
}

class EditorTabs extends StatelessComponent {
  const EditorTabs({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var isClosed = context.watch(tabsStateProvider.select((s) => s == OutputTabsState.closed));

    yield DomComponent(
      tag: 'div',
      id: 'editor-panel-footer',
      classes: ['editor-tab-host', if (isClosed) 'border-top'],
      children: [
        DomComponent(
          tag: 'div',
          classes: ['editor-tabs'],
          children: [
            DomComponent(
              tag: 'div',
              classes: ['tab-group'],
              children: [
                EditorTab(
                  id: 'editor-panel-console-tab',
                  label: 'Console',
                  value: OutputTabsState.console,
                ),
                EditorTab(
                  id: 'editor-panel-docs-tab',
                  label: 'Documentation',
                  value: OutputTabsState.docs,
                ),
                EditorTab(
                  id: 'editor-panel-issues-tab',
                  label: 'Issues',
                  value: OutputTabsState.issues,
                ),
              ],
            ),
            DomComponent(
              tag: 'div',
              id: 'console-expand-icon-container',
              children: [
                Builder(builder: (context) sync* {
                  var isConsole = context.watch(tabsStateProvider.select((s) => s == OutputTabsState.console));
                  yield DomComponent(
                    tag: 'button',
                    id: 'left-console-clear-button',
                    classes: ['console-clear-icon', 'mdc-icon-button'],
                    styles: {if (!isConsole) 'visibility': 'hidden'},
                    attributes: {'title': 'Clear console'},
                  );
                }),
                DomComponent(
                  tag: 'button',
                  id: "editor-panel-close-button",
                  classes: ["mdc-icon-button", "material-icons"],
                  attributes: {if (isClosed) 'hidden': ''},
                  events: {
                    'click': () {
                      context.read(tabsStateProvider.notifier).state = OutputTabsState.closed;
                    }
                  },
                  child: Text('close'),
                )
              ],
            ),
          ],
        ),
        if (!isClosed)
          DomComponent(
            tag: 'div',
            id: 'editor-panel-tab-host',
            styles: {'overflow': 'scroll'},
            child: EditorTabWindow(),
          ),
      ],
    );
  }
}

class EditorTab extends StatelessComponent {
  const EditorTab({required this.id, required this.label, required this.value, Key? key}) : super(key: key);

  final String id;
  final String label;
  final OutputTabsState value;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var selected = context.watch(tabsStateProvider.select((state) => state == value));

    yield DomComponent(
      tag: 'button',
      id: id,
      classes: ['editor-tab', 'mdc-button', if (selected) 'active'],
      events: {
        'click': () {
          var notifier = context.read(tabsStateProvider.notifier);
          if (selected) {
            notifier.state = OutputTabsState.closed;
          } else {
            notifier.state = value;
          }
        }
      },
      children: [Text(label)],
    );
  }
}

class EditorTabWindow extends StatelessComponent {
  const EditorTabWindow({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var state = context.watch(tabsStateProvider);

    if (state == OutputTabsState.issues) {
      var issues = context.watch(issuesProvider);

      yield DomComponent(
        tag: 'div',
        styles: {'display': 'flex', 'flex-direction': 'column'},
        children: [
          for (var issue in issues) IssueItem(issue),
        ],
      );
    } else if (state == OutputTabsState.console) {
      var messages = context.watch(consoleMessagesProvider);

      yield DomComponent(
        tag: 'div',
        styles: {'display': 'flex', 'flex-direction': 'column'},
        classes: ['console', 'custom-scrollbar'],
        children: [
          for (var msg in messages)
            DomComponent(
              tag: 'span',
              child: Text(msg, rawHtml: true),
            ),
        ],
      );
    } else if (state == OutputTabsState.docs) {
      yield DocumentPanel();
    }
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
        'click': () {
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
