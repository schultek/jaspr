part of server;

typedef SetupFunction = void Function();

class ComponentEntry<T extends Component> {
  final String name;
  final ComponentEntryType type;
  final Map<String, dynamic> Function(T component)? getParams;

  ComponentEntry.app(this.name, {this.getParams}): type = ComponentEntryType.app;
  ComponentEntry.island(this.name, {this.getParams}): type = ComponentEntryType.island;
  ComponentEntry.appAndIsland(this.name, {this.getParams}): type = ComponentEntryType.appAndIsland;

  bool get isApp => type == ComponentEntryType.app || type == ComponentEntryType.appAndIsland;
  bool get isIsland => type == ComponentEntryType.island || type == ComponentEntryType.appAndIsland;

  Map<String, dynamic> loadParams(Component component) {
    if (getParams != null) {
      var params = getParams!(component as T);
      return {'params': kDebugMode ? params : stateCodec.encode(params)};
    } else {
      return {};
    }
  }
}

enum ComponentEntryType {

  app(true, false),
  island(false, true),
  appAndIsland(true, true);

  final bool isApp;
  final bool isIsland;

  const ComponentEntryType(this.isApp, this.isIsland);
}

class ComponentRegistryData {
  final String target;
  final Map<Type, ComponentEntry> components;

  ComponentRegistryData(this.target, this.components);
}

class ComponentRegistry {
  static ComponentRegistryData? _data;

  static void initialize(String target, {required Map<Type, ComponentEntry> components}) {
    _data = ComponentRegistryData(target, components);
  }
}

/// This spawns an isolate for each render, in order to avoid conflicts with static instances and multiple parallel requests
Future<Response> _renderApp(SetupFunction setup, Request request, Future<String> Function(String) loadFile) async {
  var port = ReceivePort();

  /// We support two modes here, rendered-html and data-only
  /// rendered-html does normal ssr, but data-only only returns the preloaded state data as json
  if (request.headers['jaspr-mode'] == 'data-only') {
    var message = _RenderMessage(setup, ComponentRegistry._data, request.url, port.sendPort);

    await Isolate.spawn(_renderData, message);
    var result = await port.first;

    return Response.ok(result, headers: {'Content-Type': 'application/json'});
  } else {
    var message = _RenderMessage(setup, ComponentRegistry._data, request.url, port.sendPort);

    await Isolate.spawn(_renderHtml, message);

    var resultCompleter = Completer<String>.sync();

    var sub = port.listen((message) async {
      if (message is String) {
        resultCompleter.complete(message);
      } else if (message is LoadFileRequest) {
        message.sendPort.send(await loadFile(message.name));
      }
    });

    var result = await resultCompleter.future;
    sub.cancel();

    return Response.ok(result, headers: {'Content-Type': 'text/html'});
  }
}

class _RenderMessage {
  SetupFunction setup;
  ComponentRegistryData? registryData;
  Uri requestUri;
  SendPort sendPort;

  _RenderMessage(this.setup, this.registryData, this.requestUri, this.sendPort);
}

/// Runs the app and returns the rendered html
void _renderHtml(_RenderMessage message) async {
  AppBinding.ensureInitialized()
    ..setRegistryData(message.registryData)
    ..setCurrentUri(message.requestUri)
    ..setSendPort(message.sendPort);
  message.setup();

  var html = await AppBinding.ensureInitialized().render();
  message.sendPort.send(html);
}

/// Runs the app and returns the preloaded state data as json
void _renderData(_RenderMessage message) async {
  AppBinding.ensureInitialized()
    ..setRegistryData(message.registryData)
    ..setCurrentUri(message.requestUri);
  message.setup();

  var data = await AppBinding.ensureInitialized().data();
  message.sendPort.send(data);
}
