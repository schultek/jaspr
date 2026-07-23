import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import '../lib/main.server.dart';
import '../lib/main.server.init.dart';

void main() {
  setUpAll(() {
    initializeMappers();
  });

  group('API Integration Tests', () {
    test('/api/compile rejects absolute path in sources', () async {
      final router = apiRouter;
      
      final payload = jsonEncode({
        'sources': {
          '/tmp/jasprpad-afw-poc': 'ARBITRARY-FILE-WRITE-PoC',
          'main.dart': 'void main() {}'
        }
      });
      
      final request = Request(
        'POST',
        Uri.parse('http://localhost/compile'),
        body: payload,
        headers: {'Content-Type': 'application/json'},
      );
      
      final response = await router(request);
      expect(response.statusCode, 400);
      
      final body = await response.readAsString();
      final data = jsonDecode(body);
      expect(data['error'], contains('Invalid source file name'));
    });

    test('/api/analyze rejects absolute path in sources', () async {
      final router = apiRouter;
      
      final payload = jsonEncode({
        'sources': {
          '/tmp/jasprpad-afw-poc': 'ARBITRARY-FILE-WRITE-PoC',
          'main.dart': 'void main() {}'
        }
      });
      
      final request = Request(
        'POST',
        Uri.parse('http://localhost/analyze'),
        body: payload,
        headers: {'Content-Type': 'application/json'},
      );
      
      final response = await router(request);
      expect(response.statusCode, 400);
      
      final body = await response.readAsString();
      final data = jsonDecode(body);
      expect(data['error'], contains('Invalid source file name'));
    });

    test('/api/document rejects absolute path in sources', () async {
      final router = apiRouter;
      
      final payload = jsonEncode({
        'sources': {
          'main.dart': 'void main() {}'
        },
        'name': '/tmp/jasprpad-afw-poc',
        'offset': 0
      });
      
      final request = Request(
        'POST',
        Uri.parse('http://localhost/document'),
        body: payload,
        headers: {'Content-Type': 'application/json'},
      );
      
      final response = await router(request);
      expect(response.statusCode, 400);
      
      final body = await response.readAsString();
      final data = jsonDecode(body);
      expect(data['error'], contains('Invalid source file name'));
    });

    test('/api/download rejects absolute path in sources', () async {
      final router = apiRouter;

      final projectData = {
        'mainDartFile': 'void main() {}',
        'dartFiles': {
          '/tmp/jasprpad-afw-poc': 'ARBITRARY-FILE-WRITE-PoC'
        }
      };
      final param = base64Encode(utf8.encode(jsonEncode(projectData)));

      final request = Request(
        'GET',
        Uri.parse('http://localhost/download?project=$param'),
      );

      final response = await router(request);
      expect(response.statusCode, 400);

      final body = await response.readAsString();
      final data = jsonDecode(body);
      expect(data['error'], contains('Invalid source file name'));
    });
  });
}
