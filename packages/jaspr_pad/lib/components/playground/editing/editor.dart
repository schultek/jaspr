import 'package:collection/collection.dart';
import 'package:jaspr/jaspr.dart';

import '../../../adapters/codemirror.dart';
import '../../../models/api_models.dart';
import 'codemirror_options.dart';

class EditorDocument {
  final String key;
  final String source;
  final String mode;
  final List<Issue> issues;
  final IssueLocation? selection;

  EditorDocument({required this.key, required this.source, required this.mode, this.issues = const [], this.selection});
}

class Editor extends StatelessComponent {
  const Editor(
      {required this.activeDoc, required this.documents, this.onDocumentChanged, this.onSelectionChanged, Key? key})
      : super(key: key);

  final String? activeDoc;
  final List<EditorDocument> documents;
  final void Function(String key, String content)? onDocumentChanged;
  final void Function(String key, int index, bool isWhitespace, bool shouldNotify)? onSelectionChanged;

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
  String? _activeDoc;
  Map<String, Doc> docs = {};
  bool _lockSelection = false;

  @override
  void mount(Element? parent) {
    super.mount(parent);
    docs = {
      for (var doc in component.documents) doc.key: createDoc(doc.key, doc.source, doc.mode),
    };
    _activeDoc = component.activeDoc;
  }

  @override
  void update(covariant Editor newComponent) {
    if (kIsWeb && _editor != null) {
      var oldDocs = {...docs};
      docs = {};

      for (var document in newComponent.documents) {
        if (oldDocs.containsKey(document.key)) {
          var doc = oldDocs.remove(document.key)!;
          if (doc.getValue() != document.source) {
            doc.setValue(document.source);
          }
          docs[document.key] = doc;
        } else {
          docs[document.key] = createDoc(document.key, document.source, document.mode);
        }
        var doc = docs[document.key]!;

        // TODO check diff
        for (final marker in doc.getAllMarks()) {
          marker.clear();
        }
        for (final issue in document.issues) {
          // Create in-line squiggles.
          doc.markText(Position(issue.location.startLine, issue.location.startColumn),
              Position(issue.location.endLine, issue.location.endColumn),
              className: 'squiggle-${issue.kind.name}', title: issue.message);
        }

        if (document.selection != null) {
          var sel = document.selection!;
          _lockSelection = true;
          doc.setSelection(
            Position(sel.startLine, sel.startColumn),
            head: Position(sel.endLine, sel.endColumn),
          );
          _editor!.focus();
          _lockSelection = false;
        }
      }

      for (var doc in oldDocs.values) {
        if (_editor!.doc == doc) {
          _editor!.swapDoc(docs.values.firstOrNull ?? Doc(''));
          _activeDoc = docs.keys.firstOrNull;
        }
        doc.dispose();
      }

      if (newComponent.activeDoc != null && newComponent.activeDoc != _activeDoc) {
        assert(docs.containsKey(newComponent.activeDoc));
        _editor!.swapDoc(docs[newComponent.activeDoc!]!);
        _activeDoc = newComponent.activeDoc!;
      }
    }
    super.update(newComponent);
  }

  Doc createDoc(String key, String source, String mode) {
    var doc = Doc(source, mode);
    doc.onChange.listen((event) {
      component.onDocumentChanged?.call(key, doc.getValue() ?? '');
    });
    doc.onEvent('cursorActivity').listen((event) {
      var index = doc.indexFromPos(doc.getCursor()) ?? 0;
      final str = doc.getValue() ?? '';
      var char = index < 0 || index >= str.length ? '' : str[index];
      var isWhitespace = char != char.trim();
      component.onSelectionChanged?.call(key, index, isWhitespace, !_lockSelection);
    });
    return doc;
  }

  @override
  void render(DomBuilder b) {
    super.render(b);

    if (kIsWeb && _editor == null) {
      var element = (children.first as DomElement).source;
      _editor = CodeMirror.fromElement(element, options: codeMirrorOptions);
      if (_activeDoc != null) {
        _editor!.swapDoc(docs[_activeDoc!]!);
      }
    }
  }
}
