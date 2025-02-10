@TestOn('vm')

import 'package:jaspr/server.dart';
import 'package:jaspr_test/server_test.dart';

void main() {
  group('render test', () {
    setUpAll(() {
      Jaspr.initializeApp(useIsolates: false);
    });

    test('renders component with document', () async {
      var result = await renderComponent(div(id: 'test', []));

      expect(
          result,
          equals('<!DOCTYPE html>\n'
              '<html><head><base href="/"/></head><body><div id="test"></div></body></html>\n'
              ''));
    });

    test('renders standalone component', () async {
      var result = await renderComponent(div(id: 'test', []), standalone: true);

      expect(result, equals('<div id="test"></div>\n'));
    });
  });
}
