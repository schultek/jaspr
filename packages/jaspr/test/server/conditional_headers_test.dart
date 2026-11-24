@TestOn('vm')
library;

import 'package:jaspr/src/server/server_handler.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

/// Stands in for `shelf_static`, which reads the header the same way and
/// throws the same `FormatException` on a value it cannot parse.
Handler staticHandlerLike(void Function(DateTime?) onDate) {
  return (Request request) {
    onDate(request.ifModifiedSince);
    return Response.ok('the file');
  };
}

Request get(String path, {String? ifModifiedSince}) => Request(
  'GET',
  Uri.parse('http://localhost$path'),
  headers: {'if-modified-since': ?ifModifiedSince},
);

void main() {
  group('an if-modified-since the file handler cannot parse', () {
    test('is dropped rather than answered with a 500', () async {
      DateTime? seen;
      var called = false;
      final handler = createHandler(
        (request, render) => Response.ok('rendered page'),
        fileHandler: staticHandlerLike((date) {
          called = true;
          seen = date;
        }),
      );

      // The value a browser sends back when it is missing the space after the
      // weekday, as reported in the wild.
      final response = await handler(
        get('/main.css', ifModifiedSince: 'Thu,27 Aug 2026 20:33:22 GMT'),
      );

      expect(called, isTrue, reason: 'the file handler never ran');
      expect(seen, isNull, reason: 'the unparsable header was passed through');
      expect(response.statusCode, equals(200));
      expect(await response.readAsString(), equals('the file'));
    });

    test('a valid one is left alone', () async {
      DateTime? seen;
      final handler = createHandler(
        (request, render) => Response.ok('rendered page'),
        fileHandler: staticHandlerLike((date) => seen = date),
      );

      final response = await handler(
        get('/main.css', ifModifiedSince: 'Thu, 27 Aug 2026 20:33:22 GMT'),
      );

      expect(seen, equals(DateTime.utc(2026, 8, 27, 20, 33, 22)));
      expect(response.statusCode, equals(200));
    });

    test('no header at all is left alone', () async {
      DateTime? seen;
      var called = false;
      final handler = createHandler(
        (request, render) => Response.ok('rendered page'),
        fileHandler: staticHandlerLike((date) {
          called = true;
          seen = date;
        }),
      );

      await handler(get('/main.css'));

      expect(called, isTrue);
      expect(seen, isNull);
    });
  });
}
