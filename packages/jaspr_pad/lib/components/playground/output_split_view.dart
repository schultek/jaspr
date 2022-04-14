import 'package:jaspr/jaspr.dart';

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

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (state == OutputTabsState.closed) {
      yield component.child;
      yield EditorTabs();
    } else {}
  }
}

class EditorTabs extends StatelessComponent {
  const EditorTabs({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      id: 'editor-panel-footer',
      classes: ['editor-tab-host', 'border-top'],
      children: [
        DomComponent(
          tag: 'div',
          classes: ['editor-tabs'],
          children: [
            DomComponent(
              tag: 'div',
              classes: ['tab-group'],
              children: [
                EditorTab(id: 'editor-panel-console-tab', label: 'Console'),
                EditorTab(id: 'editor-panel-docs-tab', label: 'Documentation'),
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
                  attributes: {'title': 'Clear console'},
                ),
                DomComponent(
                  tag: 'button',
                  id: "editor-panel-close-button",
                  classes: ["mdc-icon-button", "material-icons"],
                  attributes: {'hidden': ''},
                  child: Text('close'),
                )
              ],
            )
          ],
        )
      ],
    );
  }
}

class EditorTab extends StatelessComponent {
  const EditorTab({required this.id, required this.label, Key? key}) : super(key: key);

  final String id;
  final String label;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'button',
      id: id,
      classes: ['editor-tab', 'mdc-button'],
      children: [Text(label)],
    );
  }
}
