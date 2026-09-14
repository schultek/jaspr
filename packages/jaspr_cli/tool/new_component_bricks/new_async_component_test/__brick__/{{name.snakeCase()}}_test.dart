import 'package:jaspr/server.dart';
import 'package:jaspr_test/server_test.dart';

import '{{{import}}}';

void main() {
  group('{{name.pascalCase()}}', () {
    testServer('renders correctly', (tester) async {
      // Mount the component alone in a page 
      tester.pumpComponent(Document(body: {{name.pascalCase()}}()));

      // Request the page, we expect the status to be 200 (OK)
      final response = await tester.request('/');
      expect(response.statusCode, equals(200));

      final body = response.document?.body;
      expect(body, isNotNull);

      // NOTE: the generated component only contains an empty div, make sure to update this to the expected html of your component
      final appHtml = '<div></div>';
      expect(body!.innerHtml.trim(), equals(appHtml));
    });
  });
}
