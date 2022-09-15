
part of document;

mixin DocumentBinding on BindingBase, SyncBinding {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  static DocumentBinding? _instance;
  static DocumentBinding? get instance => _instance!;

  late SendPort _sendPort;
  ComponentRegistryData? _registryData;
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

  void setRegistryData(ComponentRegistryData? registryData) {
    _registryData = registryData;
  }

  final Map<Element, ComponentEntry> _registryElements = {};

  ComponentEntry? _registerElement(Element element) {
    var data = _registryData?.components[element.component.runtimeType];
    if (data != null) {
      _registryElements[element] = data;
    }
    return data;
  }

  Future<String> renderDocument(MarkupDomRenderer renderer) async {
    var state = _document?.state;
    if (state is _ManualDocumentState) {
      state._prepareRender(getStateData());
    }

    var content = renderer.renderHtml();

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
