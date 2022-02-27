import 'package:jaspr_test/server_test.dart';

import 'basic_app.dart';

void main() {
  makeTest(bool virtual, [bool debug = false]) => () {
        late ServerTester tester;

        setUp(() async {
          tester = await ServerTester.setUp(
            () {
              Counter.initialValue = 101;
              return App();
            },
            virtual: virtual,
            debug: debug,
          );
        });

        tearDown(() async {
          await tester.tearDown();
        });

        test('should serve component', () async {
          var response = await tester.request('/');

          expect(response.statusCode, equals(200));
          expect(response.document?.body, isNotNull);

          var appHtml = '<div id="app"><div>App<button>Click Me</button>Count: 101</div></div>';

          expect(response.document!.body!.innerHtml, equals(appHtml));
        });
      };

  group('basic virtual server test', makeTest(true));

  group('basic real server test', makeTest(false));

  group('basic debug server test', makeTest(true, true));
}
