import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:jaspr/server.dart';
import 'package:test/fake.dart';

class DocumentResponse {
  DocumentResponse({required this.statusCode, required this.body, this.document});

  /// The status code of the HTTP response
  int statusCode;

  /// The body of the HTTP response
  String body;

  /// The parsed document when the request was successful
  Document? document;
}

class DataResponse {
  DataResponse({required this.statusCode, required this.data});

  /// The status code of the HTTP response
  int statusCode;

  /// The data returned by the HTTP request
  Map<String, dynamic>? data;
}

class ServerTester {
  ServerTester._();

  static Future<ServerTester> setUp(Component app,
      {String attachTo = 'body',
      SetupFunction? beforeRender,
      String? html,
      bool virtual = true,
      List<Middleware>? middleware}) async {
    var tester = ServerTester._();
    await tester._start(app, attachTo, beforeRender, html, virtual, middleware);
    return tester;
  }

  Future<void> tearDown() async {
    await app.close();
  }

  late ServerApp app;
  Handler? _handler;
  http.Client? _client;

  Future<void> _start(Component comp, String id, SetupFunction? beforeRender, String? html, bool virtual,
      List<Middleware>? middleware) async {
    var _html = html ?? '<html><head></head><body><div id="$id"></div></body></html>';

    fileHandler(Request request) {
      if (request.requestedUri.path == '/') {
        return Response.ok(_html, headers: {'content-type': 'text/html'});
      } else {
        return Response.notFound('Not Found');
      }
    }

    var appCompleter = Completer();
    app = ServerApp.run(() {
      ServerComponentsBinding.ensureInitialized().attachRootComponent(comp, attachTo: id);
    }, fileHandler)
      ..setListener((server) {
        if (!appCompleter.isCompleted) appCompleter.complete();
      });

    for (var m in middleware ?? []) {
      app.addMiddleware(m);
    }

    if (virtual) {
      app.setBuilder((handler) async {
        _handler = handler;
        return FakeHttpServer();
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

  Future<DataResponse> fetchData(String location) async {
    var uri = Uri.parse('http://${app.server!.address.host}:${app.server!.port}$location');

    int statusCode;
    String body;

    var headers = {'jaspr-mode': 'data-only'};

    if (_handler != null) {
      var response = await _handler!(Request('GET', uri, headers: headers));
      statusCode = response.statusCode;
      body = await response.readAsString();
    } else {
      var response = await _client!.get(uri, headers: headers);
      statusCode = response.statusCode;
      body = response.body;
    }

    Map<String, dynamic>? data;
    if (statusCode == 200) {
      try {
        data = jsonDecode(body) as Map<String, dynamic>;
      } catch (_) {}
    }

    return DataResponse(
      statusCode: statusCode,
      data: data,
    );
  }
}

class FakeHttpServer extends Fake implements HttpServer {
  @override
  InternetAddress get address => InternetAddress('virtual.server', type: InternetAddressType.unix);

  @override
  int get port => 0;

  @override
  Future close({bool force = false}) async {}
}
