@TestOn('vm')
library;

import 'package:jaspr/server.dart';
import 'package:jaspr_test/server_test.dart';

void main() {
  group('html test', () {
    setUpAll(() {
      Jaspr.initializeApp(useIsolates: false);
    });

    test('renders checked and indeterminate attributes correctly', () async {
      var result = await renderComponent(input(type: InputType.checkbox, checked: true, indeterminate: true));

      expect(
        result.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html><head></head><body><input type="checkbox" checked indeterminate/></body></html>\n'
          '',
        ),
      );

      result = await renderComponent(input(type: InputType.checkbox, checked: false, indeterminate: false));

      expect(
        result.body,
        equals(
          '<!DOCTYPE html>\n'
          '<html><head></head><body><input type="checkbox"/></body></html>\n'
          '',
        ),
      );
    });
  });
}
