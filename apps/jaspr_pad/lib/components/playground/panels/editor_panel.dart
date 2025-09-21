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
  Component build(BuildContext context) {
    return div(id: 'editor-panel', [
      div(id: 'editor-panel-header', classes: 'header', [
        nav([
          TabBar(
            key: ValueKey(context.watch(editProjectProvider)?.id),
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
            tabs: [for (var fileName in context.watch(fileNamesProvider)) Tab(label: fileName)],
          ),
        ]),
        div(classes: 'button-group', [
          Builder(
            builder: (context) {
              return Button(
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
            },
          ),
        ]),
      ]),
      OutputSplitView(
        key: ValueKey('output-split'),
        child: Builder(
          builder: (context) {
            var activeFile = context.watch(activeDocKeyProvider);
            return div(
              styles: Styles(
                display: Display.flex,
                position: Position.relative(),
                flexDirection: FlexDirection.column,
                flex: Flex(grow: 1),
              ),
              [
                Builder(
                  key: ValueKey('output-builder'),
                  builder: (context) {
                    var proj = context.watch(editProjectProvider);

                    if (proj == null) {
                      return Editor(key: _editorKey, activeDoc: null, documents: []);
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
                        context.read(editProjectProvider.notifier).updateContent(key, content);
                      },
                      onSelectionChanged: (key, index, isWhitespace) {
                        context.read(fileSelectionProvider(key).notifier).state = null;

                        if (!isWhitespace && proj.isDart(key)) {
                          context.read(logicProvider).document(key, index);
                        }
                      },
                    );
                  },
                ),
                if (activeFile != null && ProjectData.canDelete(activeFile))
                  button(
                    classes: 'mdc-icon-button material-icons',
                    styles: Styles(
                      position: Position.absolute(top: 4.px, right: 4.px),
                      width: 32.px,
                      height: 32.px,
                      padding: Padding.all(8.px),
                      opacity: 0.5,
                      fontSize: 16.px,
                    ),
                    events: {
                      'click': (e) async {
                        var result = await DeleteFileDialog.show(context, activeFile);
                        if (result == true) {
                          context.read(logicProvider).deleteFile(activeFile);
                        }
                      },
                    },
                    [text('delete')],
                  ),
              ],
            );
          },
        ),
      ),
    ]);
  }
}
