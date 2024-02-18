import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:jaspr/server.dart' hide Document;
import 'package:meta/meta.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

@isTest
void testServer(
  String description,
  FutureOr<void> Function(ServerTester tester) callback, {
  bool virtual = true,
  List<Middleware>? middleware,
  bool? skip,
  Timeout? timeout,
  dynamic tags,
}) {
  test(
    description,
    () async {
      var tester = ServerTester._();
      try {
        await tester._start(virtual, middleware);
        await callback(tester);
      } finally {
        await tester.app.close();
      }
    },
    skip: skip,
    timeout: timeout,
    tags: tags,
  );
}

/// A virtual response object containing the server-rendered html document.
class DocumentResponse {
  DocumentResponse({required this.statusCode, required this.body, this.document});

  /// The status code of the HTTP response
  int statusCode;

  /// The body of the HTTP response
  String body;

  /// The parsed document when the request was successful
  Document? document;
}

/// A virtual response object for a data request containing the fetched data.
class DataResponse {
  DataResponse({required this.statusCode, required this.data});

  /// The status code of the HTTP response
  int statusCode;

  /// The data returned by the HTTP request
  Map<String, dynamic>? data;
}

/// Tests a jaspr app in a simulated server environment.
///
/// You can send requests using the [request] or [fetchData] methods and evaluate the
/// server-rendered response for the given url.
class ServerTester {
  ServerTester._();

  late ServerApp app;

  Handler? _handler;
  http.Client? _client;
  final _LateComponent _comp = _LateComponent();

  Future<void> _start(bool virtual, List<Middleware>? middleware) async {
    fileHandler(Request request) {
      return Response.notFound('Not Found');
    }

    var appCompleter = Completer();
    app = _runTestApp(_comp, fileHandler)
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

  void pumpComponent(Component component) {
    _comp.component = component;
  }

  /// Perform a virtual request to your app that renders the components and returns the
  /// resulting document.
  Future<DocumentResponse> request(String location) async {
    var serverHost = app.server!.address.host;
    if (serverHost == '0.0.0.0') {
      serverHost = 'localhost';
    }
    var uri = Uri.parse('http://$serverHost:${app.server!.port}$location');

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

  /// Perform a virtual data request to your app that collects all the sync-data from
  /// the rendered components.
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

ServerApp _runTestApp(_LateComponent app, Handler fileHandler) {
  var options = Jaspr.options;
  return ServerApp.run((binding) {
    binding.initializeOptions(options);
    binding.attachRootComponent(app.component ?? Builder(builder: (_) => []));
  }, fileHandler);
}

class _LateComponent {
  Component? component;
}

class FakeHttpServer extends Fake implements HttpServer {
  @override
  InternetAddress get address => InternetAddress('virtual.server', type: InternetAddressType.unix);

  @override
  int get port => 0;

  @override
  Future close({bool force = false}) async {}
}
