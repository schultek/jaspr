part of server;

typedef SetupFunction = void Function();

/// This spawns an isolate for each render, in order to avoid conflicts with static instances and multiple parallel requests
Future<Response> _renderApp(SetupFunction setup, Request request, Response fileResponse) async {
  var port = ReceivePort();

  /// We support two modes here, rendered-html and data-only
  /// rendered-html does normal ssr, but data-only only returns the preloaded state data as json
  if (request.headers['jaspr-mode'] == 'data-only') {
    var message = _RenderMessage(setup, request.url, port.sendPort);

    await Isolate.spawn(_renderData, message);
    var result = await port.first;

    return Response.ok(result, headers: {'Content-Type': 'application/json'});
  } else {
    var indexHtml = await fileResponse.readAsString();
    var message = _HtmlRenderMessage(setup, request.url, port.sendPort, indexHtml);

    await Isolate.spawn(_renderHtml, message);
    var result = await port.first;

    return Response.ok(result, headers: {'Content-Type': 'text/html'});
  }
}

class _RenderMessage {
  SetupFunction setup;
  Uri requestUri;
  SendPort sendPort;

  _RenderMessage(this.setup, this.requestUri, this.sendPort);
}

class _HtmlRenderMessage extends _RenderMessage {
  String html;

  _HtmlRenderMessage(SetupFunction setup, Uri requestUri, SendPort sendPort, this.html)
      : super(setup, requestUri, sendPort);
}

/// Runs the app and returns the rendered html
void _renderHtml(_HtmlRenderMessage message) async {
  AppBinding.ensureInitialized().setCurrentUri(message.requestUri);
  message.setup();
  var html = await AppBinding.ensureInitialized().render(message.html);
  message.sendPort.send(html);
}

/// Runs the app and returns the preloaded state data as json
void _renderData(_RenderMessage message) async {
  AppBinding.ensureInitialized().setCurrentUri(message.requestUri);
  message.setup();
  var data = await AppBinding.ensureInitialized().data();
  message.sendPort.send(data);
}
