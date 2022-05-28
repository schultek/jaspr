import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../../models/project.dart';
import '../../../providers/edit_provider.dart';
import '../../../providers/issues_provider.dart';
import '../../../providers/logic_provider.dart';
import '../../dialogs/delete_file_dialog.dart';
import '../../dialogs/new_file_dialog.dart';
import '../../elements/button.dart';
import '../../elements/tab_bar.dart';
import '../editing/editor.dart';
import 'output_split_view.dart';

class EditorPanel extends StatefulComponent {
  EditorPanel({Key? key}) : super(key: key ?? ValueKey('editor-panel'));

  @override
  State<StatefulComponent> createState() => EditorPanelState();
}

class EditorPanelState extends State<EditorPanel> {
  final _editorKey = GlobalKey();

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      id: 'editor-panel',
      children: buildChildren(context).toList(),
    );
  }

  Iterable<Component> buildChildren(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      id: 'editor-panel-header',
      classes: ['header'],
      children: [
        DomComponent(
          tag: 'nav',
          child: TabBar(
            id: 'web-tab-bar',
            selected: context.watch(activeDocIndexProvider),
            onSelected: (index) {
              context.read(activeDocIndexProvider.notifier).state = index;
            },
            leading: ButtonTab(
              icon: 'note_add',
              onPressed: () async {
                var result = await NewFileDialog.show(context);
                if (result != null) {
                  context.read(logicProvider).addNewFile(result);
                }
              },
            ),
            tabs: [
              for (var fileName in context.watch(fileNamesProvider)) Tab(label: fileName),
            ],
          ),
        ),
        DomComponent(
          tag: 'div',
          classes: ['button-group'],
          children: [
            Builder(builder: (context) sync* {
              yield Button(
                id: 'run-button',
                dense: true,
                raised: true,
                label: 'Run',
                icon: 'play_arrow',
                disabled: context.watch(isCompilingProvider),
                onPressed: () {
                  context.read(logicProvider).compileFiles();
                },
              );
            }),
          ],
        ),
      ],
    );

    yield OutputSplitView(
      key: ValueKey('output-split'),
      child: Builder.single(builder: (context) {
        var activeFile = context.watch(activeDocKeyProvider);
        return DomComponent(
          tag: 'div',
          styles: {'position': 'relative', 'display': 'flex', 'flex': '1', 'flex-flow': 'column'},
          children: [
            Builder.single(
              key: ValueKey('output-builder'),
              builder: (context) {
                var proj = context.watch(editProjectProvider);

                if (proj == null) {
                  return Editor(
                    key: _editorKey,
                    activeDoc: null,
                    documents: [],
                  );
                }

                EditorDocument doc(String key, String mode) {
                  return EditorDocument(
                    key: key,
                    source: proj.fileContentFor(key) ?? '',
                    mode: mode,
                    issues: mode == 'dart' ? context.watch(docIssuesProvider(key)) : [],
                    selection: context.watch(fileSelectionProvider(key)),
                  );
                }

                return Editor(
                  key: _editorKey,
                  activeDoc: context.watch(activeDocKeyProvider),
                  documents: [
                    doc('main.dart', 'dart'),
                    for (var key in proj.dartFiles.keys) doc(key, 'dart'),
                    doc('index.html', 'text/html'),
                    doc('styles.css', 'css'),
                  ],
                  onDocumentChanged: (String key, String content) {
                    context.read(editProjectProvider.notifier).update((state) => state?.updateContent(key, content));
                  },
                  onSelectionChanged: (key, index, isWhitespace, shouldNotify) {
                    if (shouldNotify) {
                      context.read(fileSelectionProvider(key).notifier).state = null;
                    }
                    if (!isWhitespace && proj.isDart(key)) {
                      context.read(logicProvider).document(key, index);
                    }
                  },
                );
              },
            ),
            if (activeFile != null && ProjectData.canDelete(activeFile))
              DomComponent(
                tag: 'button',
                classes: ["mdc-icon-button", "material-icons"],
                styles: {
                  'position': 'absolute',
                  'right': '4px',
                  'top': '4px',
                  'width': '32px',
                  'height': '32px',
                  'padding': '8px',
                  'font-size': '16px',
                  'opacity': '0.5',
                },
                events: {
                  'click': (e) async {
                    var result = await DeleteFileDialog.show(context, activeFile);
                    if (result == true) {
                      context.read(logicProvider).deleteFile(activeFile);
                    }
                  }
                },
                children: [
                  Text('delete'),
                ],
              )
          ],
        );
      }),
    );
  }
}
