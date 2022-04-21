import 'package:jaspr/jaspr.dart';
import 'package:jaspr_pad/providers/logic_provider.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../../providers/docs_provider.dart';
import '../../elements/button.dart';
import '../../elements/tab_bar.dart';
import '../editing/editor.dart';
import '../output_split_view.dart';

class EditorPanel extends StatefulComponent {
  const EditorPanel({Key? key}) : super(key: key);

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
          selected: context.watch(activeFileIndexProvider),
          onSelected: (index) {
            context.read(activeFileIndexProvider.notifier).state = index;
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
      child: Editor(
        key: _editorKey,
        activeDoc: kIsWeb ? context.watch(activeDocProvider) : null,
      ),
    );
  }
}
