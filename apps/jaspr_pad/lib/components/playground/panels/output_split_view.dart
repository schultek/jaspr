import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../../models/api_models.dart';
import '../../../providers/issues_provider.dart';
import '../../../providers/project_provider.dart';
import '../../elements/hidden.dart';
import '../../elements/splitter.dart';
import '../output/execution_service.dart';
import 'console_panel.dart';
import 'document_panel.dart';
import 'issues_panel.dart';
import 'output_panel.dart';

enum OutputTabsState { closed, ui, issues, docs, console }

final tabsStateProvider = StateProvider((ref) => OutputTabsState.closed);

class OutputSplitView extends StatelessComponent {
  const OutputSplitView({required this.child, super.key});

  final Component child;

  @override
  Component build(BuildContext context) {
    context.listen<List<Issue>>(issuesProvider, (_, issues) {
      if (issues.where((i) => i.kind == IssueKind.error).isNotEmpty &&
          context.read(tabsStateProvider) == OutputTabsState.closed) {
        context.read(tabsStateProvider.notifier).state = OutputTabsState.issues;
      }
    });

    var isClosed = context.watch(tabsStateProvider.select((s) => s == OutputTabsState.closed));

    return Fragment(children: [
      if (isClosed) ...[
        child,
        EditorTabs(key: GlobalObjectKey('editor-tabs')),
      ] else
        Splitter(
          key: ValueKey('editor-splitter'),
          horizontal: false,
          initialSizes: [70, 30],
          children: [
            child,
            EditorTabs(key: GlobalObjectKey('editor-tabs')),
          ],
        ),
    ]);
  }
}

class EditorTabs extends StatelessComponent {
  const EditorTabs({super.key});

  @override
  Component build(BuildContext context) {
    var isTutorial = context.watch(isTutorialProvider);
    var isClosed = context.watch(tabsStateProvider.select((s) => s == OutputTabsState.closed));

    return div(
      id: 'editor-panel-footer',
      classes: 'editor-tab-host ${isClosed ? ' border-top' : ''}',
      [
        div(classes: 'editor-tabs', [
          div(classes: 'tab-group', [
            if (isTutorial)
              EditorTab(
                id: 'editor-panel-ui-tab',
                label: 'UI Output',
                value: OutputTabsState.ui,
              ),
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
          ]),
          div(id: 'console-expand-icon-container', [
            Builder(builder: (context) {
              var isConsole = context.watch(tabsStateProvider.select((s) => s == OutputTabsState.console));
              return button(
                id: 'left-console-clear-button',
                classes: 'console-clear-icon mdc-icon-button',
                styles: !isConsole ? Styles(visibility: Visibility.hidden) : null,
                attributes: {'title': 'Clear console'},
                events: events(onClick: () {
                  context.read(consoleMessagesProvider.notifier).state = [];
                }),
                [],
              );
            }),
            button(
              id: 'editor-panel-close-button',
              classes: 'mdc-icon-button material-icons',
              attributes: {if (isClosed) 'hidden': ''},
              events: events(onClick: () {
                context.read(tabsStateProvider.notifier).state = OutputTabsState.closed;
              }),
              [text('close')],
            ),
          ]),
        ]),
        div(id: 'editor-panel-tab-host', styles: Styles(overflow: Overflow.scroll), [
          EditorTabWindow(),
        ]),
      ],
    );
  }
}

class EditorTab extends StatelessComponent {
  const EditorTab({required this.id, required this.label, required this.value, super.key});

  final String id;
  final String label;
  final OutputTabsState value;

  @override
  Component build(BuildContext context) {
    var selected = context.watch(tabsStateProvider.select((state) => state == value));

    return button(
      id: id,
      classes: 'editor-tab mdc-button${selected ? ' active' : ''}',
      events: events(onClick: () {
        var notifier = context.read(tabsStateProvider.notifier);
        if (selected) {
          notifier.state = OutputTabsState.closed;
        } else {
          notifier.state = value;
        }
      }),
      [text(label)],
    );
  }
}

class EditorTabWindow extends StatelessComponent {
  const EditorTabWindow({super.key});

  @override
  Component build(BuildContext context) {
    var state = context.watch(tabsStateProvider);
    var isTutorial = context.watch(isTutorialProvider);

    return Fragment(children: [
      if (isTutorial)
        Hidden(
          hidden: state != OutputTabsState.ui,
          child: OutputPanel(),
        ),
      if (state == OutputTabsState.issues)
        IssuesPanel()
      else if (state == OutputTabsState.console)
        ConsolePanel()
      else if (state == OutputTabsState.docs)
        DocumentPanel(),
    ]);
  }
}
