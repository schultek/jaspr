part of 'document.dart';

mixin DocumentBinding on AppBinding {
  late Future<String> Function(String) _fileHandler;

  void setFileHandler(Future<String> Function(String) handler) {
    _fileHandler = handler;
  }

  _DocumentElement? _document;
  Future<String>? _fileRequest;

  void _loadFile(String name) {
    _fileRequest = _fileHandler(name);
  }

  Future<String> renderDocument(MarkupRenderObject root) async {
    var state = _document?.state;
    var adapters = <RenderAdapter>[];
    if (state is _BaseDocumentState) {
      state._prepareRender(getStateData());
      adapters = state.adapters;
    }

    var content = root.renderToHtml(adapters);

    if (state is _FileDocumentState && _fileRequest != null) {
      var fileContent = await _fileRequest!;

      var document = parse(fileContent);
      var appElement = document.querySelector(state.component.attachTo)!;
      appElement.innerHtml = content;

      var syncState = getStateData();
      var stateScript = document.createElement('script');
      stateScript.innerHtml = 'window.jaspr = ${JsonEncoder.withIndent(kDebugMode ? '  ' : null).convert({
            if (syncState.isNotEmpty) 'sync': kDebugMode ? syncState : stateCodec.encode(syncState),
          })};';

      document.head!.append(stateScript);
      content = document.outerHtml;
    } else {
      content = '<!DOCTYPE html>\n$content';
    }

    return content;
  }
}

class LoadFileRequest {
  final String name;
  final SendPort sendPort;

  LoadFileRequest(this.name, this.sendPort);
}
