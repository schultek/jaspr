import 'package:jaspr/jaspr.dart';

import '../../../pkg/codemirror/codemirror.dart';
import 'codemirror_options.dart';

class Editor extends StatelessComponent {
  const Editor({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      id: 'editor-host',
    );
  }

  @override
  Element createElement() => EditorElement(this);
}

class EditorElement extends StatelessElement {
  EditorElement(Editor component) : super(component);

  CodeMirror? _editor;

  @override
  void render(DomBuilder b) {
    super.render(b);

    var element = (children.first as DomElement).source;
    _editor?.dispose();
    _editor = CodeMirror.fromElement(element, options: codeMirrorOptions);
  }
}
