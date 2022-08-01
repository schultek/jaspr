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

class Editor extends StatefulComponent {
  const Editor(
      {required this.activeDoc, required this.documents, this.onDocumentChanged, this.onSelectionChanged, Key? key})
      : super(key: key);

  final String? activeDoc;
  final List<EditorDocument> documents;
  final void Function(String key, String content)? onDocumentChanged;
  final void Function(String key, int index, bool isWhitespace, bool shouldNotify)? onSelectionChanged;

  @override
  State createState() => EditorState();
}

class EditorState extends State<Editor> {
  CodeMirror? _editor;
  dynamic _editorElement;
  String? _activeDoc;
  Map<String, Doc> docs = {};
  bool _lockIsUpdating = false;

  @override
  void initState() {
    super.initState();
    docs = {
      for (var doc in component.documents) doc.key: createDoc(doc.key, doc.source, doc.mode),
    };
    _activeDoc = component.activeDoc;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield FindChildNode(
      onNodeFound: (node) {
        if (kIsWeb) {
          if (_editor == null || node.nativeElement != _editorElement) {
            _editor?.dispose();
            _editorElement = node.nativeElement;
            _editor = CodeMirror.fromElement(_editorElement!, options: codeMirrorOptions);
            if (_activeDoc != null) {
              _editor!.swapDoc(docs[_activeDoc!]!);
            }
          }
        }
      },
      child: DomComponent(
        tag: 'div',
        id: 'editor-host',
      ),
    );
  }

  @override
  void didUpdateComponent(covariant Editor oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (kIsWeb && _editor != null) {
      _lockIsUpdating = true;
      try {
        var oldDocs = {...docs};
        docs = {};

        for (var document in component.documents) {
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
            doc.setSelection(
              Position(sel.startLine, sel.startColumn),
              head: Position(sel.endLine, sel.endColumn),
            );
            _editor!.focus();
          }
        }

        for (var doc in oldDocs.values) {
          if (_editor!.doc == doc) {
            _editor!.swapDoc(docs.values.firstOrNull ?? Doc(''));
            _activeDoc = docs.keys.firstOrNull;
          }
          doc.dispose();
        }

        if (component.activeDoc != null && component.activeDoc != _activeDoc) {
          assert(docs.containsKey(component.activeDoc));
          _editor!.swapDoc(docs[component.activeDoc!]!);
          _activeDoc = component.activeDoc!;
        }
      } finally {
        _lockIsUpdating = false;
      }
    }
  }

  Doc createDoc(String key, String source, String mode) {
    var doc = Doc(source, mode);
    doc.onChange.listen((event) {
      if (!_lockIsUpdating) {
        component.onDocumentChanged?.call(key, doc.getValue() ?? '');
      }
    });
    doc.onEvent('cursorActivity').listen((event) {
      var index = doc.indexFromPos(doc.getCursor()) ?? 0;
      final str = doc.getValue() ?? '';
      var char = index < 0 || index >= str.length ? '' : str[index];
      var isWhitespace = char != char.trim();
      component.onSelectionChanged?.call(key, index, isWhitespace, !_lockIsUpdating);
    });
    return doc;
  }
}
