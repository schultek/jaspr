import 'dart:async';
import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:jaspr/server.dart';

class DocumentResponse {
  DocumentResponse({required this.statusCode, required this.body, this.document});

  /// The status code of the HTTP response
  int statusCode;

  /// The body of the HTTP response
  String body;

  /// The parsed document when the request was successful
  Document? document;
}

class ServerTester {
  ServerTester._();

  static Future<ServerTester> setUp(SetupFunction setup, {String id = 'app', String? html, bool virtual = true}) async {
    var tester = ServerTester._();
    await tester._start(setup, id, html, virtual);
    return tester;
  }

  Future<void> tearDown() async {
    await app.close();
  }

  late ServerApp app;
  Handler? _handler;
  http.Client? _client;

  Future<void> _start(SetupFunction setup, String id, String? html, bool virtual) async {
    var _html = html ?? '<html><head></head><body><div id="$id"></div></body></html>';

    fileHandler(Request request) {
      if (request.requestedUri.path == '/') {
        return Response.ok(_html, headers: {'content-type': 'text/html'});
      } else {
        return Response.notFound('Not Found');
      }
    }

    var appCompleter = Completer();
    app = ServerApp.start(setup, id, fileHandler, false)
      ..setListener((server) {
        if (!appCompleter.isCompleted) appCompleter.complete();
      });

    if (virtual) {
      app.setBuilder((handler) async {
        _handler = handler;
        return VirtualHttpServer();
      });
    } else {
      _client = http.Client();
    }

    await appCompleter.future;
  }

  Future<DocumentResponse> request(String location) async {
    var uri = Uri.parse('http://${app.server!.address.host}:${app.server!.port}$location');

    int statusCode;
    String body;

    if (_handler != null) {
      var response = await _handler!(Request('GET', uri));
      statusCode = response.statusCode;
      body = await response.readAsString();
    } else {
      var response = await _client!.get(uri);
      statusCode = response.statusCode;
      body = response.body;
    }

    var doc = statusCode == 200 ? parse(body) : null;

    return DocumentResponse(
      statusCode: statusCode,
      body: body,
      document: doc?.body != null ? doc : null,
    );
  }
}

class VirtualHttpServer extends Stream<HttpRequest> implements HttpServer {
  @override
  InternetAddress get address => InternetAddress('virtual.server', type: InternetAddressType.unix);

  @override
  int get port => 0;

  @override
  bool autoCompress = false;

  @override
  Duration? idleTimeout;

  @override
  String? serverHeader;

  @override
  set sessionTimeout(int timeout) {}

  @override
  HttpHeaders get defaultResponseHeaders => throw UnimplementedError();

  @override
  HttpConnectionsInfo connectionsInfo() => HttpConnectionsInfo();

  @override
  StreamSubscription<HttpRequest> listen(void Function(HttpRequest event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    throw UnimplementedError();
  }

  @override
  Future close({bool force = false}) async {}
}
