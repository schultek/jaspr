import 'package:jaspr/jaspr.dart';
import 'package:jaspr_pad/components/elements/splitter.dart';

import '../elements/button.dart';
import '../elements/tab_bar.dart';
import 'editing/editor.dart';
import 'output_split_view.dart';

class MainSection extends StatelessComponent {
  const MainSection({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'section',
      classes: ['main-section'],
      children: [
        DomComponent(
          tag: 'div',
          classes: ['panels'],
          child: Splitter(
            children: [
              EditorPanel(),
              OutputPanel(),
            ],
          ),
        ),
      ],
    );
  }
}

class EditorPanel extends StatelessComponent {
  const EditorPanel({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(tag: 'div', id: 'editor-panel', children: buildChildren(context));
  }

  Iterable<Component> buildChildren(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      id: 'editor-panel-header',
      classes: ['header'],
      child: DomComponent(
        tag: 'nav',
        child: TabBar(id: 'web-tab-bar'),
      ),
    );

    yield DomComponent(
      tag: 'div',
      classes: ['button-group'],
      children: [
        Button(
          id: 'run-button',
          dense: true,
          raised: true,
          label: 'Run',
          icon: 'play_arrow',
          onPressed: () {},
        ),
      ],
    );

    yield OutputSplitView(
      child: Editor(),
    );
  }
}

class OutputPanel extends StatelessComponent {
  const OutputPanel({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(tag: 'div', id: 'output-panel');
  }
}
