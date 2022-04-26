import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../../providers/edit_provider.dart';
import '../../../providers/issues_provider.dart';
import '../../../providers/logic_provider.dart';
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
    yield DomComponent(tag: 'div', id: 'editor-panel', children: buildChildren(context).toList());
  }

  Iterable<Component> buildChildren(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      id: 'editor-panel-header',
      classes: ['header'],
      child: DomComponent(
        tag: 'nav',
        child: TabBar(
          id: 'web-tab-bar',
          selected: context.watch(activeDocIndexProvider),
          onSelected: (index) {
            context.read(activeDocIndexProvider.notifier).state = index;
          },
          tabs: [
            for (var fileName in context.watch(fileNamesProvider)) Tab(label: fileName),
          ],
        ),
      ),
    );

    yield DomComponent(
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
    );

    yield OutputSplitView(
      key: ValueKey('output-split'),
      child: Builder.single(
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
          }),
    );
  }
}
