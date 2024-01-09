part of document;

mixin DocumentBinding on AppBinding {
  late SendPort _sendPort;
  ReceivePort? _receivePort;

  void setSendPort(SendPort sendPort) {
    _sendPort = sendPort;
  }

  _DocumentElement? _document;
  Future<String>? _fileRequest;

  void _loadFile(String name) {
    _receivePort ??= ReceivePort();
    _sendPort.send(LoadFileRequest(name, _receivePort!.sendPort));
    _fileRequest = _receivePort!.first.then((value) => value);
  }

  Future<String> renderDocument(MarkupRenderObject root) async {
    var state = _document?.state;
    if (state is _BaseDocumentState) {
      state._prepareRender(getStateData());
    }

    var content = root.renderToHtml();

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
