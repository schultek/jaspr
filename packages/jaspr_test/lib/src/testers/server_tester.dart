import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:jaspr/server.dart' hide Document;
import 'package:meta/meta.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

@isTest
void testServer(
  String description,
  FutureOr<void> Function(ServerTester tester) callback, {
  bool? skip,
  Timeout? timeout,
  dynamic tags,
}) {
  test(
    description,
    () async {
      var tester = ServerTester._();
      tester._start();
      await callback(tester);
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

  late Handler _handler;
  final _LateComponent _comp = _LateComponent();

  void _start() {
    var options = Jaspr.options;
    _handler = ServerApp.createTestHandler(
      (r, render) => render((binding) {
        binding.initializeOptions(options);
        binding.attachRootComponent(_comp.component ?? Builder(builder: (_) => []));
      }),
      fileHandler: (Request request) {
        return Response.notFound('Not Found');
      },
    );
  }

  void pumpComponent(Component component) {
    _comp.component = component;
  }

  /// Perform a virtual request to your app that renders the components and returns the
  /// resulting document.
  Future<DocumentResponse> request(String location) async {
    var uri = Uri.parse('http://test.server$location');

    var response = await _handler(Request('GET', uri));
    var statusCode = response.statusCode;
    var body = await response.readAsString();

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
    var uri = Uri.parse('http://test.server$location');

    var headers = {'jaspr-mode': 'data-only'};

    var response = await _handler(Request('GET', uri, headers: headers));
    var statusCode = response.statusCode;
    var body = await response.readAsString();

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
