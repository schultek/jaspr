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
  const OutputSplitView({required this.child, Key? key}) : super(key: key);

  final Component child;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    context.listen<List<Issue>>(issuesProvider, (_, issues) {
      if (issues.where((i) => i.kind == IssueKind.error).isNotEmpty &&
          context.read(tabsStateProvider) == OutputTabsState.closed) {
        context.read(tabsStateProvider.notifier).state = OutputTabsState.issues;
      }
    });

    var isClosed = context.watch(tabsStateProvider.select((s) => s == OutputTabsState.closed));

    if (isClosed) {
      yield child;
      yield EditorTabs(key: GlobalObjectKey('editor-tabs'));
    } else {
      yield Splitter(
        key: ValueKey('editor-splitter'),
        horizontal: false,
        initialSizes: [70, 30],
        children: [
          child,
          EditorTabs(key: GlobalObjectKey('editor-tabs')),
        ],
      );
    }
  }
}

class EditorTabs extends StatelessComponent {
  const EditorTabs({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var isTutorial = context.watch(isTutorialProvider);
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
                    styles: !isConsole ? Styles.box(visibility: Visibility.hidden) : null,
                    attributes: {'title': 'Clear console'},
                    events: {
                      'click': (e) {
                        context.read(consoleMessagesProvider.notifier).state = [];
                      }
                    },
                  );
                }),
                DomComponent(
                  tag: 'button',
                  id: "editor-panel-close-button",
                  classes: ["mdc-icon-button", "material-icons"],
                  attributes: {if (isClosed) 'hidden': ''},
                  events: {
                    'click': (e) {
                      context.read(tabsStateProvider.notifier).state = OutputTabsState.closed;
                    }
                  },
                  child: Text('close'),
                ),
              ],
            ),
          ],
        ),
        DomComponent(
          tag: 'div',
          id: 'editor-panel-tab-host',
          styles: Styles.box(overflow: Overflow.scroll),
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
        'click': (e) {
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
    var isTutorial = context.watch(isTutorialProvider);

    if (isTutorial) {
      yield Hidden(
        hidden: state != OutputTabsState.ui,
        child: OutputPanel(),
      );
    }

    if (state == OutputTabsState.issues) {
      yield IssuesPanel();
    } else if (state == OutputTabsState.console) {
      yield ConsolePanel();
    } else if (state == OutputTabsState.docs) {
      yield DocumentPanel();
    }
  }
}
