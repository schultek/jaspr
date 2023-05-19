import 'package:jaspr_test/server_test.dart';

import 'routing_app.dart';

void main() {
  group('routing test', () {
    late ServerTester tester;

    setUp(() async {
      tester = await ServerTester.setUp(App());
    });

    tearDown(() async {
      await tester.tearDown();
    });

    test('should handle routing', () async {
      var response = await tester.request('/');

      expect(response.statusCode, equals(200));
      expect(response.body, contains('Home'));

      response = await tester.request('/about');

      expect(response.statusCode, equals(200));
      expect(response.body, contains('About'));

      response = await tester.request('/unknown');

      expect(response.statusCode, equals(200));
      expect(response.body, contains('Unknown (&#47;unknown)'));
    });
  });
}
