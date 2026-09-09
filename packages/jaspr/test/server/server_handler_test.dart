@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:jaspr/server.dart';
import 'package:jaspr/src/server/server_handler.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:test/test.dart';

void main() {
  group('server_handler', () {
    setUpAll(() {
      Jaspr.initializeApp();
    });

    test('drains proxy response when falling through to render handler', () async {
      var streamListened = false;
      var streamDrained = false;

      // Create a mock handler that simulates a proxy returning 404 with a stream body.
      final controller = StreamController<List<int>>(
        onListen: () {
          streamListened = true;
        },
      );
      controller.add([1, 2, 3]);
      unawaited(
        controller.close().then((_) {
          streamDrained = true;
        }),
      );

      Response mockProxyHandler(Request request) {
        return Response.notFound(controller.stream);
      }

      final handler = createHandler(
        (request, render) {
          return Response.ok('rendered page');
        },
        fileHandler: mockProxyHandler,
      );

      final response = await handler(Request('GET', Uri.http('localhost', '/about')));
      expect(response.statusCode, equals(200));
      expect(await response.readAsString(), equals('rendered page'));

      // Wait a tick to allow microtasks to finish.
      await Future.pause(Duration(milliseconds: 50));

      expect(streamListened, isTrue, reason: 'The 404 response body stream must be listened to');
      expect(streamDrained, isTrue, reason: 'The 404 response body stream must be drained');
    });

    test('drains real shelf_proxy response on 404 fallthrough', () async {
      // Upstream server stands in for dev asset server, returning 404 for non-asset requests.
      final upstream = await io.serve((_) => Response.notFound('Not a static file'), InternetAddress.loopbackIPv4, 0);

      final client = http.Client();
      final proxy = proxyHandler('http://localhost:${upstream.port}/', client: client);

      final handler = createHandler(
        (request, render) {
          return Response.ok('rendered page');
        },
        fileHandler: proxy,
        client: client,
      );

      // Make multiple requests through the handler
      for (var i = 0; i < 5; i++) {
        final response = await handler(Request('GET', Uri.http('localhost', '/about')));
        expect(response.statusCode, equals(200));
        expect(await response.readAsString(), equals('rendered page'));
      }

      client.close();
      await upstream.close(force: true);
    });

    test('proxyFileLoader drains non-200 responses', () async {
      var streamListened = false;
      var streamDrained = false;

      final controller = StreamController<List<int>>(
        onListen: () {
          streamListened = true;
        },
      );
      controller.add([1, 2, 3]);
      unawaited(
        controller.close().then((_) {
          streamDrained = true;
        }),
      );

      Response mockProxyHandler(Request request) {
        return Response.notFound(controller.stream);
      }

      final loader = proxyFileLoader(Request('GET', Uri.http('localhost', '/about')), mockProxyHandler);
      final result = await loader('index.html');

      expect(result, isNull);

      await Future.pause(Duration(milliseconds: 50));
      expect(streamListened, isTrue, reason: 'proxyFileLoader must listen to 404 body stream');
      expect(streamDrained, isTrue, reason: 'proxyFileLoader must drain 404 body stream');
    });
  });
}
