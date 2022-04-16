import 'package:jaspr/jaspr.dart';

import '../elements/splitter.dart';

enum OutputTabsState { closed, ui, docs, console }

class InheritedOutputTabsComponent extends InheritedComponent {
  InheritedOutputTabsComponent({required this.state, required Component child}) : super(child: child);

  final OutputTabsState state;

  @override
  bool updateShouldNotify(covariant InheritedOutputTabsComponent oldComponent) {
    return state != oldComponent.state;
  }
}

class OutputSplitView extends StatefulComponent {
  const OutputSplitView({required this.child, Key? key}) : super(key: key);

  final Component child;

  @override
  State<OutputSplitView> createState() => _OutputSplitViewState();
}

class _OutputSplitViewState extends State<OutputSplitView> {
  OutputTabsState state = OutputTabsState.closed;

  void toggleConsole() {
    setState(() {
      if (state == OutputTabsState.console) {
        state = OutputTabsState.closed;
      } else {
        state = OutputTabsState.console;
      }
    });
  }

  void toggleDocs() {
    setState(() {
      if (state == OutputTabsState.docs) {
        state = OutputTabsState.closed;
      } else {
        state = OutputTabsState.docs;
      }
    });
  }

  void closePanel() {
    setState(() {
      state = OutputTabsState.closed;
    });
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (state == OutputTabsState.closed) {
      yield component.child;
      yield EditorTabs();
    } else {
      yield Splitter(
        horizontal: false,
        initialSizes: [70, 30],
        children: [
          component.child,
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
    var state = context.findAncestorStateOfType<_OutputSplitViewState>()!.state;
    yield DomComponent(
      tag: 'div',
      id: 'editor-panel-footer',
      classes: ['editor-tab-host', if (state == OutputTabsState.closed) 'border-top'],
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
                  selected: state == OutputTabsState.console,
                  onPressed: () {
                    context.findAncestorStateOfType<_OutputSplitViewState>()!.toggleConsole();
                  },
                ),
                EditorTab(
                  id: 'editor-panel-docs-tab',
                  label: 'Documentation',
                  selected: state == OutputTabsState.docs,
                  onPressed: () {
                    context.findAncestorStateOfType<_OutputSplitViewState>()!.toggleDocs();
                  },
                ),
              ],
            ),
            DomComponent(
              tag: 'div',
              id: 'console-expand-icon-container',
              children: [
                DomComponent(
                  tag: 'button',
                  id: 'left-console-clear-button',
                  classes: ['console-clear-icon', 'mdc-icon-button'],
                  styles: {if (state != OutputTabsState.console) 'visibility': 'hidden'},
                  attributes: {'title': 'Clear console'},
                ),
                DomComponent(
                  tag: 'button',
                  id: "editor-panel-close-button",
                  classes: ["mdc-icon-button", "material-icons"],
                  attributes: {if (state == OutputTabsState.closed) 'hidden': ''},
                  events: {
                    'click': () {
                      context.findAncestorStateOfType<_OutputSplitViewState>()!.closePanel();
                    }
                  },
                  child: Text('close'),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class EditorTab extends StatelessComponent {
  const EditorTab({required this.id, required this.label, this.selected = false, required this.onPressed, Key? key})
      : super(key: key);

  final String id;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'button',
      id: id,
      classes: ['editor-tab', 'mdc-button', if (selected) 'active'],
      events: {'click': onPressed},
      children: [Text(label)],
    );
  }
}
