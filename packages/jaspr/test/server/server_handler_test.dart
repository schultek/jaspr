@TestOn('vm')
library;

import 'dart:convert';

import 'package:jaspr/src/server/server_handler.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

/// A response body that records whether anyone consumed it.
///
/// The generator's body does not run until the stream is listened to, so
/// [listened] says whether something subscribed and [drained] whether it was
/// read to the end.
class _RecordingBody {
  bool listened = false;
  bool drained = false;

  Stream<List<int>> call() async* {
    listened = true;
    yield utf8.encode('from the file handler');
    drained = true;
  }
}

Request _get(String path) => Request('GET', Uri.parse('http://localhost$path'));

void main() {
  group('createHandler', () {
    test('drains a file handler response the cascade skips past', () async {
      final body = _RecordingBody();
      final handler = createHandler(
        (request, render) => Response.ok('rendered page'),
        fileHandler: (_) => Response.notFound(body()),
      );

      final response = await handler(_get('/about'));

      expect(response.statusCode, equals(200));
      expect(await response.readAsString(), equals('rendered page'));
      // Nothing is going to read the 404 the file handler produced, so this
      // handler has to. Left alone, its socket stays open for the lifetime of
      // the server: in development that is one connection to the webdev proxy
      // per page view.
      expect(body.drained, isTrue, reason: 'the skipped response was not drained');
    });

    test('leaves a served file alone', () async {
      final body = _RecordingBody();
      final handler = createHandler(
        (request, render) => Response.ok('rendered page'),
        fileHandler: (_) => Response.ok(body()),
      );

      final response = await handler(_get('/main.dart.js'));

      expect(response.statusCode, equals(200));
      expect(await response.readAsString(), equals('from the file handler'));
      expect(body.drained, isTrue);
    });

    test('does not render a path with a suffix it does not allow', () async {
      final body = _RecordingBody();
      final handler = createHandler(
        (request, render) => Response.ok('rendered page'),
        fileHandler: (_) => Response.notFound(body()),
      );

      final response = await handler(_get('/missing.png'));

      expect(response.statusCode, equals(404));
      expect(body.drained, isTrue);
    });
  });

  group('proxyFileLoader', () {
    test('returns the file it was given', () async {
      final loader = proxyFileLoader(_get('/about'), (_) => Response.ok(_RecordingBody()()));

      expect(await loader('index.html'), equals('from the file handler'));
    });

    test('drains a file it did not get', () async {
      final body = _RecordingBody();
      final loader = proxyFileLoader(_get('/about'), (_) => Response.notFound(body()));

      expect(await loader('index.html'), isNull);
      expect(body.drained, isTrue, reason: 'the unread response was not drained');
    });
  });
}
