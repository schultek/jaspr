import 'package:jaspr_test/server_test.dart';

import 'preload_data_app.dart';

void main() {
  group('preload data test', () {
    late ServerTester tester;

    setUp(() async {
      tester = await ServerTester.setUp(App.new);
    });

    tearDown(() async {
      await tester.tearDown();
    });

    test('should preload data', () async {
      var response = await tester.request('/');

      expect(response.statusCode, equals(200));

      var body = response.document?.body;
      expect(body, isNotNull);

      var appHtml = '<div id="app"><div>App<button>Click Me</button>Count: 202</div></div>';
      expect(body!.innerHtml, equals(appHtml));

      expect(body.attributes, equals({'data-state-counter': '202'}));
    });
  });
}
