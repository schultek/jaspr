import 'package:jaspr/jaspr.dart';

import '../../../adapters/codemirror.dart';
import 'codemirror_options.dart';

class Editor extends StatelessComponent {
  const Editor({required this.activeDoc, Key? key}) : super(key: key);

  final Doc? activeDoc;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      id: 'editor-host',
      child: SkipRenderComponent(),
    );
  }

  @override
  Element createElement() => EditorElement(this);
}

class EditorElement extends StatelessElement {
  EditorElement(Editor component) : super(component);

  @override
  Editor get component => super.component as Editor;

  CodeMirror? _editor;

  @override
  void update(covariant Editor newComponent) {
    super.update(newComponent);
    if (kIsWeb) {
      _editor?.swapDoc(newComponent.activeDoc!);
    }
  }

  @override
  void render(DomBuilder b) {
    super.render(b);

    if (kIsWeb && _editor == null) {
      var element = (children.first as DomElement).source;
      _editor = CodeMirror.fromElement(element, options: codeMirrorOptions);
      _editor!.swapDoc(component.activeDoc!);
    }
  }
}
