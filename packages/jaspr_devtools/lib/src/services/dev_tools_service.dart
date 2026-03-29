import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:jaspr/jaspr.dart';
import 'package:sse/client/sse_client.dart';
import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart';
import 'package:web/web.dart' as web;

class JasprDevToolsService with ChangeNotifier {
  VmService? clientVmService;
  VmService? serverVmService;

  String? _clientUri;
  String? _serverUri;

  JasprDevToolsService() {
    _initEvents();
  }

  void _initEvents() {
    final client = SseClient('/\$jasprDevToolsEvents');
    client.stream.listen(
      (String event) {
        if (event.isNotEmpty) {
          final decoded = jsonDecode(event) as Map<String, dynamic>;
          _updateUris(
            decoded['clientVmServiceUri'] as String?,
            decoded['serverVmServiceUri'] as String?,
          );
        }
      },
      onDone: () {
        print('JasprDevToolsService: SSE stream closed');
        _disposeVmServices();
        notifyListeners();
      },
      onError: (Object? error) {
        print('JasprDevToolsService: SSE stream error: $error');
      },
    );
  }

  Future<void> _updateUris(String? newClientUri, String? newServerUri) async {
    bool changed = false;

    if (newClientUri != _clientUri && newClientUri != null) {
      _clientUri = newClientUri;
      clientVmService = await _connectToVmService(newClientUri);
      clientVmService?.streamListen('Extension');
      changed = true;
    }

    if (newServerUri != _serverUri && newServerUri != null) {
      _serverUri = newServerUri;
      serverVmService = await _connectToVmService(newServerUri);
      serverVmService?.streamListen('Extension');
      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  Future<VmService?> _connectToVmService(String uri) async {
    try {
      final wsUri = convertToWebSocketUrl(serviceProtocolUrl: Uri.parse(uri)).toString();
      final webSocket = web.WebSocket(wsUri);

      final inController = StreamController<dynamic>();
      final messageSub = web.EventStreamProvider<web.MessageEvent>('message').forTarget(webSocket).listen((event) {
        final data = event.data;
        if (data != null) {
          inController.add((data as JSString).toDart);
        }
      });

      final streamClosedCompleter = Completer<void>();
      web.EventStreamProvider<web.Event>('close').forTarget(webSocket).listen((event) {
        inController.close();
        messageSub.cancel();
        streamClosedCompleter.complete();
      });

      await web.EventStreamProvider<web.Event>('open').forTarget(webSocket).first;

      return VmService(
        inController.stream,
        (String str) => webSocket.send(str.toJS),
        disposeHandler: () async => webSocket.close(),
        streamClosed: streamClosedCompleter.future,
        wsUri: wsUri,
      );
    } catch (e) {
      print('Failed to connect to VM service at $uri: $e');
      return null;
    }
  }

  void _disposeVmServices() {
    clientVmService?.dispose();
    serverVmService?.dispose();
    clientVmService = null;
    serverVmService = null;
    _clientUri = null;
    _serverUri = null;
  }

  @override
  void dispose() {
    _disposeVmServices();
    super.dispose();
  }
}
